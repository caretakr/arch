##
## Firewall
##

_main() {
  _log 'Setting firewall...'

  (set -ex
    arch-chroot /mnt systemctl enable firewalld.service
  ) || exit
}
