##
## Packages
##

_main() {
  _install_home="$(mktemp -du -p /var/tmp -t install-XXXXXXXX)"

  _log 'Refreshing pacman keys...'

  (set -ex
    arch-chroot /mnt rm -R /etc/pacman.d/gnupg

    arch-chroot /mnt pacman-key --init
    arch-chroot /mnt pacman-key --populate archlinux
  ) || exit

  _log 'Installing system packages...'

  (set -ex
    _packages=" \
      aardvark-dns \
      alsa-plugins \
      alsa-utils \
      base-devel \
      bluez \
      bluez-utils \
      brightnessctl \
      btop \
      buildah \
      clang \
      cliphist \
      crane \
      delve \
      dive \
      dmidecode \
      dnsmasq \
      dosfstools \
      efibootmgr \
      exfatprogs \
      firewalld \
      foot \
      fscrypt \
      fwupd \
      fzf \
      gammastep \
      gcr \
      git \
      gnome-themes-extra \
      gnupg \
      go \
      gopls \
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
      jdk-openjdk \
      jq \
      kanshi \
      keepassxc \
      kubectl \
      kvantum \
      ldd \
      less \
      libc++ \
      libfido2 \
      libnotify \
      libsecret \
      libsodium \
      libvirt \
      links \
      linux-lts \
      linux-zen \
      mako \
      man-db \
      man-pages \
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
      passt \
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
      slurp \
      sof-firmware \
      sudo \
      sway \
      swaybg \
      swayidle \
      swaylock \
      swtpm \
      terminus-font \
      textinfo \
      tmux \
      trash-cli \
      ttf-firacode-nerd \
      udiskie \
      udisks2 \
      unarchiver \
      unzip \
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
      zsh-syntax-highlighting
    "

    if \
      [ "$(dmidecode -s system-manufacturer)" = 'Dell Inc.' ] \
        && [ "$(dmidecode -s system-product-name)" = 'XPS 13 9310' ]
    then
      _packages=" \
        $_packages \
        iio-sensor-proxy \
        intel-media-driver \
      "
    fi

    if \
      [ "$(dmidecode -s system-manufacturer)" = 'Apple Inc.' ] \
        && [ "$(dmidecode -s system-product-name)" = 'MacBookPro9,2' ]
    then
      _packages=" \
        $_packages \
        broadcom-wl \
        libva-intel-driver \
      "
    fi

    arch-chroot /mnt pacman -S \
      --needed \
      --noconfirm \
      --ask=4 \
      $_packages
  ) || exit

  _log 'Creating install user...'

  (set -ex
    arch-chroot /mnt useradd -mr \
      -d "$_install_home" \
      install
  ) || exit

  _log 'Adding temporary sudo...'

  (set -ex
    cat <<EOF | arch-chroot /mnt tee /etc/sudoers.d/90-install
install ALL=(ALL) NOPASSWD: ALL
EOF
  ) || exit

  _log 'Installing AUR packages...'

  (set -ex
    _packages="
      downgrade \
      paru-bin \
      zsh-theme-powerlevel10k-git \
    "

    for _package in $_packages; do
      arch-chroot /mnt sudo -u install sh -c " \
        git clone https://aur.archlinux.org/${_package}.git \
          ${_install_home}/${_package} \
          && cd ${_install_home}/${_package} \
          && makepkg -si --needed --noconfirm \
      "
    done
  ) || exit

  _log 'Generating paru devel database...'

  (set -ex
    arch-chroot /mnt paru --gendb
  ) || exit

  _log 'Removing temporary sudo...'

  (set -ex
    arch-chroot /mnt rm -rf /etc/sudoers.d/90-install
  ) || exit

  _log 'Removing install user...'

  (set -ex
    arch-chroot /mnt userdel -r install
  ) || exit

  rm -rf "$_install_home"
}
