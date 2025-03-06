##
## Hardening
##

_main() {
  _log 'Setting hardening...'

  (set -ex
    arch-chroot /mnt tee /etc/sysctl.d/90-namespaces.conf \
      < $(dirname "$0")/../src/assets/etc/sysctl.d/90-namespaces.conf
  ) || exit
}
