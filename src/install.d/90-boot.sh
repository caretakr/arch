##
## Boot
##

_main() {
  _data_uuid="$(blkid -s UUID -o value "/dev/${DATA_PARTITION}")"

  _arch_version="$(date +%Y.%m).01"
  _grml_version="2024.12"

  _rescue_workdir="$(mktemp -d -p /mnt/var/tmp -t rescue-XXXXXXXX)"

  _log 'Setting boot...'

  (set -ex
    arch-chroot /mnt bootctl --esp-path=/efi --boot-path=/boot install

    arch-chroot /mnt tee /boot/loader/loader.conf \
      < $(dirname "$0")/../src/assets/boot/loader/loader.conf

    sed \
      -e "s/{{ data_uuid }}/${_data_uuid}/g" \
      $(dirname "$0")/../src/assets/boot/loader/entries/linux.conf.tpl \
      | arch-chroot /mnt tee /boot/loader/entries/linux.conf

    sed \
      -e "s/{{ data_uuid }}/${_data_uuid}/g" \
      $(dirname "$0")/../src/assets/boot/loader/entries/linux-fallback.conf.tpl \
      | arch-chroot /mnt tee /boot/loader/entries/linux-fallback.conf

    sed \
      -e "s/{{ data_uuid }}/${_data_uuid}/g" \
      $(dirname "$0")/../src/assets/boot/loader/entries/linux-lts.conf.tpl \
      | arch-chroot /mnt tee /boot/loader/entries/linux-lts.conf

    sed \
      -e "s/{{ data_uuid }}/${_data_uuid}/g" \
      $(dirname "$0")/../src/assets/boot/loader/entries/linux-lts-fallback.conf.tpl \
      | arch-chroot /mnt tee /boot/loader/entries/linux-lts-fallback.conf

    sed \
      -e "s/{{ data_uuid }}/${_data_uuid}/g" \
      $(dirname "$0")/../src/assets/boot/loader/entries/linux-zen.conf.tpl \
      | arch-chroot /mnt tee /boot/loader/entries/linux-zen.conf

    sed \
      -e "s/{{ data_uuid }}/${_data_uuid}/g" \
      $(dirname "$0")/../src/assets/boot/loader/entries/linux-zen-fallback.conf.tpl \
      | arch-chroot /mnt tee /boot/loader/entries/linux-zen-fallback.conf
  ) || exit 900

  _log 'Installing rescue...'

  (set -ex
    cd "$_rescue_workdir"

    curl -fsSL \
      -o "archlinux-${_arch_version}-x86_64.iso" \
      "https://geo.mirror.pkgbuild.com/iso/${_arch_version}/archlinux-${_arch_version}-x86_64.iso"

    bsdtar xf "archlinux-${_arch_version}-x86_64.iso" \
      "arch/boot/x86_64/initramfs-linux.img" \
      "arch/boot/x86_64/vmlinuz-linux" \
      "arch/x86_64/airootfs.sfs"

    install -d /mnt/boot/rescue

    install arch/boot/x86_64/initramfs-linux.img /mnt/boot/rescue/initramfs-linux.img
    install arch/boot/x86_64/vmlinuz-linux /mnt/boot/rescue/vmlinuz-linux
    install arch/x86_64/airootfs.sfs /mnt/boot/rescue/airootfs.sfs
  ) || exit 901

  _log 'Setting rescue...'

  (set -ex
    arch-chroot /mnt tee /boot/loader/entries/rescue.conf \
      < $(dirname "$0")/../src/assets/boot/loader/entries/rescue.conf
  ) || exit 902

  _log 'Setting silent...'

  (set -ex
    arch-chroot /mnt setterm -cursor on >> /etc/issue

    arch-chroot /mnt tee /etc/sysctl.d/20-quiet.conf \
      < $(dirname "$0")/../src/assets/etc/sysctl.d/20-quiet.conf

    mkdir -p /mnt/etc/systemd/system/getty@tty7.service.d

    arch-chroot /mnt tee /etc/systemd/system/getty@tty7.service.d/override.conf \
      < $(dirname "$0")/../src/assets/etc/systemd/system/getty@tty7.service.d/override.conf

    arch-chroot /mnt systemctl enable getty@tty7.service \
      && arch-chroot /mnt systemctl disable getty@tty1.service
  ) || exit 903

  rm -rf "$_rescue_workdir"
}
