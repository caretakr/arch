#!/bin/sh

#
# Install
#

set -e

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root: exiting..."; exit
fi

_log() {
    printf "\n▶ $1\n\n"
}

_main() {
    _log "Please provide the following:"

    printf "▶ Storage device: "; read _STORAGE_DEVICE

    if [ ! -b /dev/$_STORAGE_DEVICE ]; then
        _log "Storage device not found: exiting..."; exit
    fi

    printf "▶ Data password: "; read -s _DATA_PASSWORD && printf "\n"
    printf "▶ Data password confirmation: "; read -s _DATA_PASSWORD_CONFIRMATION && printf "\n"

    if [ "$_DATA_PASSWORD" != "$_DATA_PASSWORD_CONFIRMATION" ]; then
        _log "Data password mismatch: exiting..."; exit
    fi

    printf "▶ User name: "; read _USER_NAME
    printf "▶ User password: "; read -s _USER_PASSWORD && printf "\n"
    printf "▶ User password confirmation: "; read -s _USER_PASSWORD_CONFIRMATION && printf "\n"

    if [ "$_USER_PASSWORD" != "$_USER_PASSWORD_CONFIRMATION" ]; then
        _log "User password mismatch: exiting..."; exit
    fi

    _BOOT_PARTITION="${_STORAGE_DEVICE}1"
    _SWAP_PARTITION="${_STORAGE_DEVICE}2"
    _DATA_PARTITION="${_STORAGE_DEVICE}3"

    _SWAP_SIZE="$(($(awk '( $1 == "MemTotal:" ) { printf "%3.0f", ($2/1024)*1.5 }' /proc/meminfo)*2048))"
    _DATA_START="$(($_SWAP_SIZE+2099200))"

    _log "Updating system clock..."

    timedatectl set-ntp true

    _log "Checking previous states..."

    if cat /proc/mounts | grep /mnt/boot >/dev/null; then
        _log "Unmounting boot partition..."

        umount /mnt/boot
    fi

    if cat /proc/mounts | grep /mnt/root >/dev/null; then
        _log "Unmounting root home partition..."

        umount /mnt/root
    fi

    if cat /proc/mounts | grep /mnt/home/$_USER_NAME >/dev/null; then
        _log "Unmounting user home partition..."

        umount /mnt/home/$_USER_NAME
    fi

    if cat /proc/mounts | grep /mnt/var/log >/dev/null; then
        _log "Unmounting log partition..."

        umount /mnt/var/log
    fi

    if cat /proc/mounts | grep /mnt/var/lib/libvirt/images >/dev/null; then
        _log "Unmounting libvirt images partition..."

        umount /mnt/var/lib/libvirt/images
    fi

    if cat /proc/mounts | grep /mnt >/dev/null; then
        _log "Unmounting root partition..."

        umount /mnt
    fi

    if [ -b /dev/mapper/$_DATA_PARTITION ]; then
        _log "Closing encrypted device..."

        cryptsetup close $_DATA_PARTITION
    fi

    _log "Partitioning device..."

    sfdisk "/dev/$_STORAGE_DEVICE" <<EOF
label: gpt
device: /dev/$_STORAGE_DEVICE
unit: sectors
first-lba: 2048
sector-size: 512

/dev/$_BOOT_PARTITION: start=2048, size=2097152, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B
/dev/$_SWAP_PARTITION: start=2099200, size=$_SWAP_SIZE, type=0657FD6D-A4AB-43C4-84E5-0933C84B4F4F
/dev/$_DATA_PARTITION: start=$_DATA_START, size=, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4
EOF

    _log "Encrypting data partition..."

    printf $_DATA_PASSWORD | cryptsetup luksFormat /dev/$_DATA_PARTITION -d -

    _log "Opening data partition..."

    printf $_DATA_PASSWORD | cryptsetup luksOpen /dev/$_DATA_PARTITION \
        $_DATA_PARTITION -d -

    _log "Formatting boot partition..."

    mkfs.fat -F 32 /dev/$_BOOT_PARTITION

    _log "Formatting swap partition..."

    mkswap /dev/$_SWAP_PARTITION

    _log "Formatting data partition..."

    mkfs.btrfs -f /dev/mapper/$_DATA_PARTITION

    _log "Mounting data partition..."

    mount /dev/mapper/$_DATA_PARTITION /mnt

    _log "Creating subvolume for root..."

    mkdir -p /mnt/ROOT+SNAPSHOTS
    btrfs subvolume create /mnt/ROOT+LIVE

    _log "Creating subvolume for root home..."

    mkdir -p /mnt/root+SNAPSHOTS
    btrfs subvolume create /mnt/root+LIVE

    _log "Creating subvolume for user home..."

    mkdir -p /mnt/home/$_USER_NAME+SNAPSHOTS
    btrfs subvolume create /mnt/home/$_USER_NAME+LIVE

    _log "Creating subvolume for logs..."

    mkdir -p /mnt/var/log+SNAPSHOTS
    btrfs subvolume create /mnt/var/log+LIVE

    _log "Creating subvolume for libvirt images..."

    mkdir -p /mnt/var/lib/libvirt/images+SNAPSHOTS
    btrfs subvolume create /mnt/var/lib/libvirt/images+LIVE

    _log "Unmouting data partition..."

    umount /mnt

    _log "Mounting root subvolume..."

    mount -o noatime,compress=zstd,subvol=ROOT+LIVE \
        /dev/mapper/$_DATA_PARTITION /mnt

    _log "Creating mount points..."

    mkdir -p /mnt/{boot,root,home/$_USER_NAME,var/lib/libvirt/images,var/log}

    _log "Mounting boot partition..."

    mount -o umask=0077 /dev/$_BOOT_PARTITION /mnt/boot

    _log "Mounting root home subvolume..."

    mount -o noatime,compress=zstd,subvol=root+LIVE \
        /dev/mapper/$_DATA_PARTITION /mnt/root

    _log "Mounting user home subvolume..."

    mount -o noatime,compress=zstd,subvol=home/$_USER_NAME+LIVE \
        /dev/mapper/$_DATA_PARTITION /mnt/home/$_USER_NAME

    _log "Mounting logs subvolume..."

    mount -o noatime,compress=zstd,subvol=var/log+LIVE \
        /dev/mapper/$_DATA_PARTITION /mnt/var/log

    _log "Mounting libvirt images subvolume..."
        
    mount -o noatime,nodatacow,compress=zstd,subvol=var/lib/libvirt/images+LIVE \
        /dev/mapper/$_DATA_PARTITION /mnt/var/lib/libvirt/images

    _log "Bootstrapping..."

    _PACKAGES=" \
        adwaita-qt5 \
        adwaita-qt6 \
        alsa-utils \
        alsa-plugins \
        base \
        base-devel \
        bluez \
        bluez-utils \
        bridge-utils \
        brightnessctl \
        bspwm \
        btop \
        btrfs-progs \
        dmidecode \
        dnsmasq \
        dosfstools \
        dunst \
        efibootmgr \
        feh \
        firewalld \
        flatpak \
        git \
        gnome-keyring \
        gnupg \
        gstreamer \
        gstreamer-vaapi \
        gst-libav \
        gst-plugin-pipewire \
        gst-plugins-bad \
        gst-plugins-base \
        gst-plugins-good \
        gst-plugins-ugly \
        gtk3 \
        gtk4 \
        intel-ucode \
        iptables-nft \
        iwd \
        kitty \
        libsecret \
        libvdpau-va-gl \
        libvirt \
        linux \
        linux-firmware \
        linux-headers \
        mate-polkit \
        mesa \
        mkinitcpio \
        noto-fonts \
        noto-fonts-cjk \
        noto-fonts-emoji \
        openbsd-netcat \
        openssh \
        openvpn \
        picom \
        pinentry \
        pipewire \
        pipewire-alsa \
        pipewire-jack \
        pipewire-pulse \
        playerctl \
        podman \
        polkit \
        polybar \
        rofi \
        rsync \
        seahorse \
        slock \
        sof-firmware \
        sudo \
        systemd-resolvconf \
        sxhkd \
        qemu-full \
        qt5-base \
        qt6-base \
        vim \
        virt-manager \
        vulkan-intel \
        wireguard-tools \
        wireplumber \
        xorg-server \
        xorg-xinit \
        xorg-xinput \
        xorg-xrandr \
        xorg-xset \
        xss-lock \
        zsh
    "

    if \
        [ "$(dmidecode -s system-manufacturer)" = "Dell Inc." ] \
            && [ "$(dmidecode -s system-product-name)" = "XPS 13 9310" ]
    then
        _PACKAGES=" \
            $_PACKAGES \
            iio-sensor-proxy \
            intel-media-driver \
            sof-firmware \
        "
    fi

    if \
        [ "$(dmidecode -s system-manufacturer)" = "Apple Inc." ] \
            && [ "$(dmidecode -s system-product-name)" = "MacBookPro9,2" ]
    then
        _PACKAGES=" \
            $_PACKAGES \
            broadcom-wl \
            libva-intel-driver \
        "
    fi

    pacstrap /mnt $_PACKAGES

    _log "Setting file system table..."

    genfstab -U /mnt >> /mnt/etc/fstab

    _log "Setting timezone..."

    arch-chroot /mnt ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
    arch-chroot /mnt hwclock --systohc

    _log "Setting locale..."

    sed -i '/^#en_US.UTF-8 UTF-8/s/^#//g' /mnt/etc/locale.gen
    sed -i '/^#pt_BR.UTF-8 UTF-8/s/^#//g' /mnt/etc/locale.gen

    arch-chroot /mnt locale-gen

    _log "Setting language..."

    cat <<EOF > /mnt/etc/locale.conf
LANG=en_US.UTF-8
EOF

    _log "Setting console..."

    if \
        [ "$(dmidecode -s system-manufacturer)" = "Dell Inc." ] \
            && [ "$(dmidecode -s system-product-name)" = "XPS 13 9310" \
    ]; then
        _KEYMAP="br-abnt2"
    fi

    if \
        [ "$(dmidecode -s system-manufacturer)" = "Apple Inc." ] \
            && [ "$(dmidecode -s system-product-name)" = "MacBookPro9,2" \
    ]; then
        _KEYMAP="us"
    fi

    cat <<EOF > /mnt/etc/vconsole.conf
KEYMAP=$_KEYMAP
EOF

    _log "Setting hosts..."

    cat <<EOF > /mnt/etc/hostname
arch
EOF

    cat <<EOF > /mnt/etc/hosts
127.0.0.1 localhost
::1 localhost
127.0.1.1 arch.localdomain arch
EOF

    _log "Setting network..."

    mkdir -p /mnt/etc/systemd/network

    cat <<EOF > /mnt/etc/systemd/network/20-ethernet.network
[Match]
Name=en*

[Network]
DHCP=yes

[DHCPv4]
RouteMetric=10

[IPv6AcceptRA]
RouteMetric=10
EOF

    cat <<EOF > /mnt/etc/systemd/network/25-wireless.network
[Match]
Name=wl*

[Network]
DHCP=yes

[DHCPv4]
RouteMetric=20

[IPv6AcceptRA]
RouteMetric=20
EOF

    _log "Setting user..."

    arch-chroot /mnt useradd -G wheel -m -s /bin/zsh $_USER_NAME
    arch-chroot /mnt chown $_USER_NAME:$_USER_NAME /home/$_USER_NAME
    arch-chroot /mnt chmod 0700 /home/$_USER_NAME

    _log "Setting passwords..."

    echo "$_USER_NAME:$_USER_PASSWORD" | arch-chroot /mnt chpasswd

    _log "Setting sudoers..."

    cat <<EOF > /mnt/etc/sudoers.d/20-admin
%wheel ALL=(ALL:ALL) ALL
EOF

cat <<EOF > /mnt/etc/sudoers.d/99-install
ALL ALL=(ALL:ALL) NOPASSWD: ALL
EOF

    _log "Setting home"...

    arch-chroot /mnt sudo -u $_USER_NAME sh -c \
        "(git clone https://github.com/$_USER_NAME/home.git /home/$_USER_NAME && cd /home/$_USER_NAME && git submodule init && git submodule update)"

    _log "Setting Paru..."

    arch-chroot /mnt sudo -u $_USER_NAME git clone \
        https://aur.archlinux.org/paru.git /var/tmp/paru

    arch-chroot /mnt sudo -u $_USER_NAME sh -c \
        "(cd /var/tmp/paru && makepkg -si --noconfirm && cd / && rm -rf /var/tmp/paru)"

    _log "Setting AUR packages..."

    arch-chroot /mnt sudo -u $_USER_NAME paru -S --noconfirm \
        plymouth \
        xbanish

    _log "Setting ramdisk..."

    sed -i '/^MODULES/s/(.*)/(btrfs)/g' /mnt/etc/mkinitcpio.conf
    sed -i '/^HOOKS/s/(.*)/(base udev plymouth autodetect keyboard keymap consolefont modconf block plymouth-encrypt filesystems fsck)/g' /mnt/etc/mkinitcpio.conf

    arch-chroot /mnt mkinitcpio -P

    _log "Setting bootloader..."

    arch-chroot /mnt bootctl install

    cat <<EOF > /mnt/boot/loader/loader.conf
default arch
EOF

    cat <<EOF > /mnt/boot/loader/entries/arch.conf
title Arch
linux /vmlinuz-linux
initrd /initramfs-linux.img
options cryptdevice=UUID=$(blkid -s UUID -o value /dev/$_DATA_PARTITION):root:allow-discards root=UUID=$(blkid -s UUID -o value /dev/mapper/$_DATA_PARTITION) rootflags=subvol=ROOT+LIVE rw quiet splash loglevel=3 rd.systemd.show_status=auto rd.udev.log_level=3 vt.global_cursor_default=0 i915.enable_psr=0 i915.enable_fbc=1
EOF

    cat <<EOF > /mnt/boot/loader/entries/arch-fallback.conf
title Arch (fallback)
linux /vmlinuz-linux
initrd /initramfs-linux-fallback.img
options cryptdevice=UUID=$(blkid -s UUID -o value /dev/$_DATA_PARTITION):root:allow-discards root=UUID=$(blkid -s UUID -o value /dev/mapper/$_DATA_PARTITION) rootflags=subvol=ROOT+LIVE rw quiet splash loglevel=3 rd.systemd.show_status=auto rd.udev.log_level=3 vt.global_cursor_default=0 i915.enable_psr=0 i915.enable_fbc=1
EOF

    _log "Setting clean boot..."

    arch-chroot /mnt touch /root/.hushlogin

    arch-chroot /mnt touch /home/$_USER_NAME/.hushlogin
    arch-chroot /mnt chown $_USER_NAME:$_USER_NAME /home/$_USER_NAME/.hushlogin

    arch-chroot /mnt setterm -cursor on >> /etc/issue

    cat <<EOF > /mnt/etc/sysctl.d/20-quiet.conf
kernel.printk = 3 3 3 3
EOF

    mkdir -p /mnt/etc/systemd/system/getty@tty1.service.d

    cat <<EOF > /mnt/etc/systemd/system/getty@tty1.service.d/login.conf
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --skip-login --nonewline --noissue --autologin $_USER_NAME --noclear %I \$TERM
EOF

    _log "Enable services and timers..."

    arch-chroot /mnt systemctl enable bluetooth.service
    arch-chroot /mnt systemctl enable firewalld.service
    arch-chroot /mnt systemctl enable fstrim.timer
    arch-chroot /mnt systemctl enable iwd.service
    arch-chroot /mnt systemctl enable libvirtd.service
    arch-chroot /mnt systemctl enable systemd-networkd.service
    arch-chroot /mnt systemctl enable systemd-resolved.service

    _log "Cleanup..."

    rm -f /mnt/etc/sudoers.d/99-install
}

_main "$@"