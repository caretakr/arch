##
## Mirrors
##

_main() {
  _log 'Setting mirrors...'

  (set -ex
    arch-chroot /mnt mkdir -p /etc/systemd/system/reflector.service.d

    arch-chroot /mnt tee /etc/systemd/system/reflector.service.d/override.conf \
      < $(dirname "$0")/../src/assets/etc/systemd/system/reflector.service.d/override.conf

    arch-chroot /mnt systemctl enable reflector.timer
  ) || exit
}
