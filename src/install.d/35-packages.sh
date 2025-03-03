##
## Packages
##

_main() {
  _log 'Refreshing pacman keys...'

  (set -ex
    arch-chroot /mnt rm -R /etc/pacman.d/gnupg

    arch-chroot /mnt pacman-key --init
    arch-chroot /mnt pacman-key --populate archlinux
  ) || exit

  _log 'Installing system packages...'

  (set -ex
    _packages=" \
      alsa-plugins \
      alsa-utils \
      base-devel \
      bluez \
      bluez-utils \
      brightnessctl \
      dosfstools \
      efibootmgr \
      exfatprogs \
      firewalld \
      fwupd \
      git \
      intel-gpu-tools \
      intel-ucode \
      iwd \
      libva-utils \
      man-db \
      man-pages \
      mesa \
      mesa-utils \
      openssh \
      pipewire \
      pipewire-alsa \
      pipewire-audio \
      pipewire-jack \
      pipewire-pulse \
      plymouth \
      reflector \
      sof-firmware \
      sudo \
      terminus-font \
      udisks2 \
      vulkan-icd-loader \
      vulkan-intel \
      vulkan-tools \
      wireplumber \
      zsh \
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
}
