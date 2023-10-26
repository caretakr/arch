##
## Sudo
##

_main() {
  _log 'Setting sudo...'

  (set -ex
    arch-chroot /mnt tee /etc/sudoers.d/20-admin \
      < $(dirname "$0")/../src/assets/etc/sudoers.d/20-admin
  ) || exit 49
}
