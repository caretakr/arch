##
## Packages
##

_main() {
  INSTALL_HOME="$(mktemp -d)"

  _log 'Refreshing pacman keys...'

  (set -ex
    arch-chroot /mnt rm -R /etc/pacman.d/gnupg

    arch-chroot /mnt pacman-key --init
    arch-chroot /mnt pacman-key --populate archlinux
  ) || exit 18

  _log 'Installing system packages...'

  (set -ex
    packages=" \
      aardvark-dns \
      alsa-plugins \
      alsa-utils \
      base-devel \
      bluez \
      bluez-utils \
      brightnessctl \
      btop \
      btrfs-progs \
      cliphist \
      dmidecode \
      dnsmasq \
      dosfstools \
      efibootmgr \
      firewalld \
      flatpak \
      foot \
      fwupd \
      fzf \
      gammastep \
      git \
      gnome-themes-extra \
      gnupg \
      grim \
      grml-zsh-config \
      gst-libav \
      gst-plugin-pipewire \
      gst-plugins-bad \
      gst-plugins-base \
      gst-plugins-good \
      gst-plugins-ugly \
      gstreamer \
      gstreamer-vaapi \
      gtk2 \
      gtk3 \
      gtk4 \
      intel-ucode \
      iptables-nft \
      iwd \
      jq \
      kanshi \
      keepassxc \
      kubectl \
      kvantum \
      less \
      libfido2 \
      libnotify \
      libsecret \
      libsodium \
      libvirt \
      links \
      mako \
      man \
      mesa \
      minikube \
      netavark \
      noto-fonts \
      noto-fonts-cjk \
      noto-fonts-emoji \
      neovim \
      openbsd-netcat \
      openssh \
      pam-u2f \
      parallel \
      pinentry \
      pipewire \
      pipewire-alsa \
      pipewire-jack \
      pipewire-pulse \
      playerctl \
      plymouth \
      podman \
      polkit \
      polkit-gnome \
      privoxy \
      qemu-full \
      qemu-user-static \
      qemu-user-static-binfmt \
      qt5-base \
      qt5-svg \
      qt5-wayland \
      qt6-base \
      qt6-svg \
      qt6-wayland \
      reflector \
      ripgrep \
      rsync \
      shadowsocks \
      slirp4netns \
      slurp \
      sof-firmware \
      sudo \
      sway \
      swaybg \
      swayidle \
      swaylock \
      swtpm \
      tmux \
      trash-cli \
      ttf-firacode-nerd \
      udiskie \
      udisks2 \
      unarchiver \
      virt-manager \
      vulkan-intel \
      waybar \
      wireguard-tools \
      wireplumber \
      wl-clipboard \
      xdg-desktop-portal \
      xdg-desktop-portal-gtk \
      xdg-desktop-portal-wlr \
      xdg-user-dirs \
      xorg-xwayland \
      zoxide \
      zsh \
      zsh-autosuggestions \
      zsh-history-substring-search \
      zsh-syntax-highlighting \
      zsh-theme-powerlevel10k \
    "

    if \
      [ "$(dmidecode -s system-manufacturer)" = 'Dell Inc.' ] \
        && [ "$(dmidecode -s system-product-name)" = 'XPS 13 9310' ]
    then
      packages=" \
        $packages \
        iio-sensor-proxy \
        intel-media-driver \
      "
    fi

    if \
      [ "$(dmidecode -s system-manufacturer)" = 'Apple Inc.' ] \
        && [ "$(dmidecode -s system-product-name)" = 'MacBookPro9,2' ]
    then
      packages=" \
        $packages \
        broadcom-wl \
        libva-intel-driver \
      "
    fi

    arch-chroot /mnt pacman -S \
      --needed \
      --noconfirm \
      --ask=4 \
      $packages
  ) || exit 19
  
  _log 'Creating install user...'

  (set -ex
    arch-chroot /mnt useradd -mr -d "$INSTALL_HOME" install
  ) || exit 20

  _log 'Adding temporary sudo...'

  (set -ex
    cat <<EOF | arch-chroot /mnt tee /etc/sudoers.d/90-install
install ALL=(ALL) NOPASSWD: ALL
EOF
  ) || exit 21
  
  _log 'Installing AUR packages...'

  (set -ex
    packages="
      paru-bin \
    "

    for package in $packages; do
      arch-chroot /mnt sudo -u install sh -c " \
        git clone https://aur.archlinux.org/${package}.git \
          ${INSTALL_HOME}/${package} \
          && cd ${INSTALL_HOME}/${package} \
          && makepkg -si --needed --noconfirm \
      "
    done
  ) || exit 22

  _log 'Generating paru devel database...'

  (set -ex
    arch-chroot /mnt paru --gendb
  ) || exit 23

  _log 'Removing temporary sudo...'

  (set -ex
    arch-chroot /mnt rm -rf /etc/sudoers.d/90-install
  ) || exit 24
  
  _log 'Removing install user...'

  (set -ex
    arch-chroot /mnt userdel -r install
  ) || exit 25
}
