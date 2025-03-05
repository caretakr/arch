##
## Packages
##

_main() {
  _pacman_home="$(mktemp -du -p /var/tmp -t pacman-XXXXXXXX)"

  _log 'Refreshing pacman keys...'

  (set -ex
    arch-chroot /mnt rm -R /etc/pacman.d/gnupg

    arch-chroot /mnt pacman-key --init
    arch-chroot /mnt pacman-key --populate archlinux
  ) || exit

  _log 'Installing system packages...'

  (set -ex
    _packages=" \
      adwaita-icon-theme \
      alsa-plugins \
      alsa-utils \
      base-devel \
      bluez \
      bluez-utils \
      brightnessctl \
      btop \
      buildah \
      cliphist \
      dmidecode \
      dnsmasq \
      dosfstools \
      dunst \
      edk2-ovmf \
      efibootmgr \
      exfatprogs \
      firewalld \
      foot \
      fscrypt \
      fwupd \
      fzf \
      gcr \
      gettext \
      git \
      gnome-themes-extra \
      gnupg \
      grim \
      grml-zsh-config \
      gstreamer \
      gst-libav \
      gst-plugin-pipewire \
      gst-plugin-va \
      gst-plugins-bad \
      gst-plugins-base \
      gst-plugins-good \
      gst-plugins-ugly \
      gtk2 \
      gtk3 \
      gtk4 \
      hyprcursor \
      hypridle \
      hyprland \
      hyprlock \
      hyprpaper \
      hyprsunset \
      intel-gpu-tools \
      intel-ucode \
      iptables-nft \
      iwd \
      jq \
      kanshi \
      keepassxc \
      kvantum \
      kvantum-qt5 \
      libappindicator-gtk3 \
      libfido2 \
      libnotify \
      libsecret \
      libva \
      libva-utils \
      libvirt \
      linux-zen \
      mailcap \
      man-db \
      man-pages \
      mesa \
      mesa-utils \
      neovim \
      netavark \
      noto-fonts \
      noto-fonts-cjk \
      noto-fonts-emoji \
      noto-fonts-extra \
      openbsd-netcat \
      openssh \
      perl-file-mimeinfo \
      pinentry \
      pipewire \
      pipewire-alsa \
      pipewire-audio \
      pipewire-jack \
      pipewire-pulse \
      playerctl \
      plymouth \
      podman \
      polkit \
      polkit-gnome \
      qemu-full \
      qemu-user-static \
      qemu-user-static-binfmt \
      qt5-base \
      qt5-svg \
      qt5-wayland \
      qt5ct \
      qt6-base \
      qt6-svg \
      qt6-wayland \
      qt6ct \
      reflector \
      ripgrep \
      rsync \
      slurp \
      sof-firmware \
      sudo \
      swtpm \
      terminus-font \
      tmuxp \
      trash-cli \
      ttf-firacode-nerd \
      udiskie \
      udisks2 \
      unarchiver \
      vim \
      virt-manager \
      vulkan-icd-loader \
      vulkan-intel \
      vulkan-tools \
      waybar \
      wireguard-tools \
      wireplumber \
      wl-clipboard \
      xdg-desktop-portal-gtk \
      xdg-desktop-portal-hyprland \
      xdg-user-dirs \
      xdg-utils \
      zoxide \
      zsh \
      zsh-autosuggestions \
      zsh-completions \
      zsh-history-substring-search \
      zsh-syntax-highlighting \
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
        vulkan-swrast \
      "
    fi

    arch-chroot /mnt pacman -S \
      --needed \
      --noconfirm \
      --ask=4 \
      $_packages
  ) || exit

  _log 'Creating Pacman user...'

  (set -ex
    arch-chroot /mnt useradd -mr \
      -d "$_pacman_home" \
      pacman
  ) || exit

  _log 'Installing user packages...'

  (set -ex
    _packages="
      librewolf-bin \
      yay-bin \
      zsh-theme-powerlevel10k-git \
    "

    for _package in $_packages; do
      arch-chroot /mnt sudo -u pacman sh -c '
        git clone https://aur.archlinux.org/'$_package'.git \
          '$_pacman_home'/'$_package' \
          && cd '$_pacman_home'/'$_package' \
          && makepkg -si --needed --noconfirm
      '
    done
  ) || exit

  _log 'Removing temporary sudo...'

  (set -ex
    arch-chroot /mnt rm -rf /etc/sudoers.d/90-pacman
  ) || exit

  _log 'Removing Pacman user...'

  (set -ex
    arch-chroot /mnt userdel -r pacman
  ) || exit
}
