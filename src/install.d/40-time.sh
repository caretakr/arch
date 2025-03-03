##
## Time
##

_main() {
  _log 'Setting time...'

  (set -ex
    arch-chroot /mnt mkdir -p /etc/systemd/timesyncd.conf.d

    arch-chroot /mnt tee /etc/systemd/timesyncd.conf.d/override.conf \
      < $(dirname "$0")/../src/assets/etc/systemd/timesyncd.conf.d/override.conf

    arch-chroot /mnt systemctl enable systemd-timesyncd.service

    arch-chroot /mnt ln -sf /usr/share/zoneinfo/America/Sao_Paulo \
      /etc/localtime

    arch-chroot /mnt hwclock --systohc
  ) || exit
}
