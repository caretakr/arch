##
## Swap
##

_main() {
  _log 'Setting swap...'

  (set -ex
    arch-chroot /mnt tee /etc/sysctl.d/10-swap.conf \
      < $(dirname "$0")/../src/assets/etc/sysctl.d/10-swap.conf
  ) || exit 418
}

