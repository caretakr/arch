##
## Network
##

_main() {
  _log 'Setting network...'

  (set -ex
    sed \
      -e "s/{{ hostname }}/${HOSTNAME}/g" \
      $(dirname "$0")/../src/assets/etc/hostname.tpl \
      | arch-chroot /mnt tee /etc/hostname

    sed \
      -e "s/{{ hostname }}/${HOSTNAME}/g" \
      $(dirname "$0")/../src/assets/etc/hosts.tpl \
      | arch-chroot /mnt tee /etc/hosts

    arch-chroot /mnt tee /etc/systemd/network/20-ethernet.network \
      < $(dirname "$0")/../src/assets/etc/systemd/network/20-ethernet.network

    arch-chroot /mnt tee /etc/systemd/network/20-wireless.network \
      < $(dirname "$0")/../src/assets/etc/systemd/network/20-wireless.network

    arch-chroot /mnt systemctl enable systemd-networkd.service

    ln -sf /run/systemd/resolve/stub-resolv.conf /mnt/etc/resolv.conf

    arch-chroot /mnt systemctl enable systemd-resolved.service

    arch-chroot /mnt systemctl enable iwd.service
  ) || exit
}
