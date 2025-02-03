##
## Arch
##

_main() {
  _log 'Setting arch...'

  (set -ex
    arch-chroot /mnt systemctl enable systemd-binfmt.service
  ) || exit 400
}
