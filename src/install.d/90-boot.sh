##
## Boot
##

_main() {
  _data_uuid="$(blkid -s UUID -o value "/dev/${DATA_PARTITION}")"

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

    arch-chroot /mnt setterm -cursor on >> /etc/issue

    arch-chroot /mnt tee /etc/sysctl.d/20-quiet.conf \
      < $(dirname "$0")/../src/assets/etc/sysctl.d/20-quiet.conf

    mkdir -p /mnt/etc/systemd/system/getty@tty7.service.d

    arch-chroot /mnt tee /etc/systemd/system/getty@tty7.service.d/override.conf \
      < $(dirname "$0")/../src/assets/etc/systemd/system/getty@tty7.service.d/override.conf

    arch-chroot /mnt systemctl enable getty@tty7.service \
      && arch-chroot /mnt systemctl disable getty@tty1.service
  ) || exit 900
}
