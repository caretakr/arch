##
## Filesystem
##

_main() {
  boot_uuid="$(blkid -s UUID -o value "/dev/${boot_partition}")"
  swap_uuid="$(blkid -s UUID -o value "/dev/${swap_partition}")"
  root_uuid="$(blkid -s UUID -o value /dev/mapper/root)"

  boot_blockdev_target="blockdev@dev-disk-by\\\\x2duuid-$(echo "$boot_uuid" | sed 's/-/\\\\x2d/g').target"
  boot_systemd_fsck_service="systemd-fsck@dev-disk-by\\\\x2duuid-$(echo "$boot_uuid" | sed 's/-/\\\\x2d/g').service"

  swap_uuid_device="dev-disk-by\\\\x2duuid-$(echo "$swap_uuid" | sed 's/-/\\\\x2d/g').device"

  root_blockdev_target="blockdev@dev-disk-by\\\\x2duuid-$(echo "$root_uuid" | sed 's/-/\\\\x2d/g').target"

  _log 'Setting filesystem...'

  (set -ex
    sed \
      -e "s/{{ root_blockdev_target }}/${root_blockdev_target}/g" \
      -e "s/{{ root_uuid }}/${root_uuid}/g" \
      $(dirname "$0")/../src/assets/etc/systemd/system/-.mount.tpl \
      | arch-chroot /mnt tee /etc/systemd/system/-.mount

    arch-chroot /mnt systemctl enable -- -.mount

    sed \
      -e "s/{{ boot_blockdev_target }}/${boot_blockdev_target}/g" \
      -e "s/{{ boot_systemd_fsck_service }}/${boot_systemd_fsck_service}/g" \
      -e "s/{{ boot_uuid }}/${boot_uuid}/g" \
      $(dirname "$0")/../src/assets/etc/systemd/system/boot.mount.tpl \
      | arch-chroot /mnt tee /etc/systemd/system/boot.mount

    arch-chroot /mnt systemctl enable boot.mount

    sed \
      -e "s/{{ root_blockdev_target }}/${root_blockdev_target}/g" \
      -e "s/{{ root_uuid }}/${root_uuid}/g" \
      $(dirname "$0")/../src/assets/etc/systemd/system/home-caretakr.mount.tpl \
      | arch-chroot /mnt tee "/etc/systemd/system/home-caretakr.mount"

    arch-chroot /mnt systemctl enable home-caretakr.mount

    sed \
      -e "s/{{ root_blockdev_target }}/${root_blockdev_target}/g" \
      -e "s/{{ root_uuid }}/${root_uuid}/g" \
      $(dirname "$0")/../src/assets/etc/systemd/system/root.mount.tpl \
      | arch-chroot /mnt tee /etc/systemd/system/root.mount

    arch-chroot /mnt systemctl enable root.mount

    sed \
      -e "s/{{ root_blockdev_target }}/${root_blockdev_target}/g" \
      -e "s/{{ root_uuid }}/${root_uuid}/g" \
      $(dirname "$0")/../src/assets/etc/systemd/system/var.mount.tpl \
      | arch-chroot /mnt tee /etc/systemd/system/var.mount

    arch-chroot /mnt systemctl enable var.mount

    sed \
      -e "s/{{ swap_uuid }}/${swap_uuid}/g" \
      -e "s/{{ swap_uuid_device }}/${swap_uuid_device}/g" \
      $(dirname "$0")/../src/assets/etc/systemd/system/dev-mapper-swap.service.tpl \
      | arch-chroot /mnt tee /etc/systemd/system/dev-mapper-swap.service

    arch-chroot /mnt systemctl enable dev-mapper-swap.service

    arch-chroot /mnt tee /etc/systemd/system/dev-mapper-swap.swap \
      < $(dirname "$0")/../src/assets/etc/systemd/system/dev-mapper-swap.swap

    arch-chroot /mnt systemctl enable dev-mapper-swap.swap
  ) || exit 29
}
