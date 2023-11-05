##
## Virt
##

_main() {
  _log 'Setting virt...'

  (set -ex
    arch-chroot /mnt systemctl enable libvirtd.service
  ) || exit 47
}
