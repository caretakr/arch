##
## Virtualization
##

_main() {
  _log 'Setting virtualization...'

  (set -ex
    arch-chroot /mnt systemctl enable libvirtd.service
  ) || exit 47
}
