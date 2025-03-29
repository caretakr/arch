##
## Containers
##

_main() {
  _log 'Setting containers...'

  (set -ex
    arch-chroot /mnt tee /etc/subuid \
      < $(dirname "$0")/../src/assets/etc/subuid

    arch-chroot /mnt tee /etc/subgid \
      < $(dirname "$0")/../src/assets/etc/subgid
  ) || exit
}

