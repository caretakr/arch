##
## NTP
##

_main() {
  _log 'Setting NTP...'

  (set -ex
    arch-chroot /mnt mkdir -p /etc/systemd/timesyncd.conf.d

    arch-chroot /mnt tee /etc/systemd/timesyncd.conf.d/override.conf \
      < $(dirname "$0")/../src/assets/etc/systemd/timesyncd.conf.d/override.conf

    arch-chroot /mnt systemctl enable systemd-timesyncd.service
  ) || exit 413
}
