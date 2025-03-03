##
## Bluetooth
##

_main() {
  _log 'Setting Bluetooth...'

  (set -ex
    arch-chroot /mnt systemctl enable bluetooth.service

    arch-chroot /mnt tee /etc/systemd/system/bluetooth-toggle.service \
      < $(dirname "$0")/../src/assets/etc/systemd/system/bluetooth-toggle.service

    arch-chroot /mnt systemctl enable bluetooth-toggle.service
  ) || exit
}
