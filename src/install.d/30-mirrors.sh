##
## Mirrors
##

_main() {
  _log 'Setting mirrors...'

  (set -ex
    arch-chroot /mnt tee /etc/systemd/system/rank-mirrors.service \
      < $(dirname "$0")/../src/assets/etc/systemd/system/rank-mirrors.service

    arch-chroot /mnt tee /etc/systemd/system/rank-mirrors.timer \
      < $(dirname "$0")/../src/assets/etc/systemd/system/rank-mirrors.timer

    arch-chroot /mnt systemctl enable rank-mirrors.timer
  ) || exit 33
}
