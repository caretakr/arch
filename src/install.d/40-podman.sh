##
## Podman
##

_main() {
  _log 'Setting Podman...'

  (set -ex
    arch-chroot /mnt tee /etc/subuid \
      < $(dirname "$0")/../src/assets/etc/subuid

    arch-chroot /mnt tee /etc/subgid \
      < $(dirname "$0")/../src/assets/etc/subgid

    arch-chroot /mnt tee /etc/sysctl.d/90-namespaces.conf \
      < $(dirname "$0")/../src/assets/etc/sysctl.d/90-namespaces.conf
  ) || exit 415
}
