##
## Boot
##

_main() {
  _log 'Setting boot...'

  (set -ex
    arch-chroot /mnt bootctl install

    arch-chroot /mnt find /boot \
      | sed -e "s/[^-][^\/]*\// |/g" -e "s/|\([^ ]\)/|-\1/"

    arch-chroot /mnt tee /boot/loader/loader.conf \
      < $(dirname "$0")/../src/assets/boot/loader/loader.conf

    sed \
      -e "s/{{ data_uuid }}/$(blkid -s UUID -o value "/dev/${data_partition}")/g" \
      -e "s/{{ root_uuid }}/$(blkid -s UUID -o value /dev/mapper/root)/g" \
      $(dirname "$0")/../src/assets/boot/loader/entries/arch.conf.tpl \
      | arch-chroot /mnt tee /boot/loader/entries/arch.conf

    sed \
      -e "s/{{ data_uuid }}/$(blkid -s UUID -o value "/dev/${data_partition}")/g" \
      -e "s/{{ root_uuid }}/$(blkid -s UUID -o value /dev/mapper/root)/g" \
      $(dirname "$0")/../src/assets/boot/loader/entries/arch-fallback.conf.tpl \
      | arch-chroot /mnt tee /boot/loader/entries/arch-fallback.conf

    arch-chroot /mnt touch /root/.hushlogin /home/caretakr/.hushlogin
    arch-chroot /mnt chown caretakr:caretakr /home/caretakr/.hushlogin

    arch-chroot /mnt setterm -cursor on >> /etc/issue

    arch-chroot /mnt tee /etc/sysctl.d/20-quiet.conf \
      < $(dirname "$0")/../src/assets/etc/sysctl.d/20-quiet.conf

    mkdir -p /mnt/etc/systemd/system/getty@tty7.service.d

    arch-chroot /mnt tee /etc/systemd/system/getty@tty7.service.d/override.conf \
      < $(dirname "$0")/../src/assets/etc/systemd/system/getty@tty7.service.d/override.conf

    arch-chroot /mnt systemctl enable getty@tty7.service
  ) || exit 50
}
