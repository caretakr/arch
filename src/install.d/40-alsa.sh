##
## ALSA
##

_main() {
  _log 'Setting ALSA...'

  (set -ex
    arch-chroot /mnt tee /etc/asound.conf \
      < $(dirname "$0")/../src/assets/etc/asound.conf
  ) || exit
}
