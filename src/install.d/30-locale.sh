##
## Locale
##

_main() {
  _log 'Generating locales...'

  (set -ex
    arch-chroot /mnt sed -i '/^#en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
    arch-chroot /mnt sed -i '/^#pt_BR.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
    
    arch-chroot /mnt locale-gen
  ) || exit 31

  _log 'Setting locales...'

  (set -ex
    arch-chroot /mnt tee /etc/locale.conf \
      < $(dirname "$0")/../src/assets/etc/locale.conf
  ) || exit 32
}
