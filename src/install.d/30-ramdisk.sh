##
## ramdisk
##

_main() {
  _log 'Setting ramdisk...'

  (set -ex
    arch-chroot /mnt tee /etc/mkinitcpio.conf.d/override.conf \
      < $(dirname "$0")/../src/assets/etc/mkinitcpio.conf.d/override.conf

    arch-chroot /mnt mkinitcpio -P
  ) || exit 42
}
