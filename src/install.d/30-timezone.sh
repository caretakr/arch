##
## Timezone
##

_main() {
  _log 'Setting timezone...'

  (set -ex
    arch-chroot /mnt ln -sf /usr/share/zoneinfo/America/Sao_Paulo \
      /etc/localtime
    
    arch-chroot /mnt hwclock --systohc
  ) || exit 46
}
