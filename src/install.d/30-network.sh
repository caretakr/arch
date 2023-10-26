##
## Network
##

_main() {
  _log 'Setting hostname...'

  (set -ex
    sed \
      -e "s/{{ hostname }}/$hostname/g" \
      $(dirname "$0")/../src/assets/etc/hostname.tpl \
      | arch-chroot /mnt tee /etc/hostname
  ) || exit 34
  
  _log 'Setting hosts...'

  (set -ex
    sed \
      -e "s/{{ hostname }}/$hostname/g" \
      $(dirname "$0")/../src/assets/etc/hosts.tpl \
      | arch-chroot /mnt tee /etc/hosts
  ) || exit 35
  
  _log 'Setting network...'
  
  (set -ex
    arch-chroot /mnt tee /etc/systemd/network/20-ethernet.network \
      < $(dirname "$0")/../src/assets/etc/systemd/network/20-ethernet.network

    arch-chroot /mnt tee /etc/systemd/network/20-wireless.network \
      < $(dirname "$0")/../src/assets/etc/systemd/network/20-wireless.network

    arch-chroot /mnt systemctl enable systemd-networkd.service
  ) || exit 36

  _log 'Setting resolver...'

  (set -ex
    ln -sf /run/systemd/resolve/stub-resolv.conf /mnt/etc/resolv.conf

    arch-chroot /mnt systemctl enable systemd-resolved.service
  ) || exit 37

  _log 'Setting wireless..'

  (set -ex
    arch-chroot /mnt systemctl enable iwd.service
  ) || exit 38
}
