##
## OOMD
##

_main() {
  _log 'Setting OOMD...'

  (set -ex
    arch-chroot /mnt mkdir -p /etc/systemd/system/user@.service.d

    arch-chroot /mnt tee /etc/systemd/system/user@.service.d/override.conf \
      < $(dirname "$0")/../src/assets/etc/systemd/system/user@.service.d/override.conf
    
    arch-chroot /mnt mkdir -p /etc/systemd/system/-.slice.d

    arch-chroot /mnt tee /etc/systemd/system/-.slice.d/override.conf \
      < $(dirname "$0")/../src/assets/etc/systemd/system/-.slice.d/override.conf
    
    arch-chroot /mnt systemctl enable systemd-oomd.service
  ) || exit 40
}

