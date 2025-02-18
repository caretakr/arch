##
## Filesystem
##

_main() {
  _boot_uuid="$(blkid -s UUID -o value "/dev/${BOOT_PARTITION}")"
  _efi_uuid="$(blkid -s UUID -o value "/dev/${EFI_PARTITION}")"
  _data_uuid="$(blkid -s UUID -o value "/dev/${DATA_PARTITION}")"
  _swap_uuid="$(blkid -s UUID -o value "/dev/${SWAP_PARTITION}")"

  _root_uuid="$(blkid -s UUID -o value "/dev/mapper/luks-${_data_uuid}")"

  _boot_blockdev_target="blockdev@dev-disk-by\\\\x2duuid-$(echo "${_boot_uuid}" | sed 's/-/\\\\x2d/g').target"
  _efi_blockdev_target="blockdev@dev-disk-by\\\\x2duuid-$(echo "${_efi_uuid}" | sed 's/-/\\\\x2d/g').target"
  _root_blockdev_target="blockdev@dev-disk-by\\\\x2duuid-$(echo "${_root_uuid}" | sed 's/-/\\\\x2d/g').target"
  _swap_blockdev_target="blockdev@dev-mapper-luks\\\\x2d$(echo "${_swap_uuid}" | sed 's/-/\\\\x2d/g').target"

  _boot_systemd_fsck_service="systemd-fsck@dev-disk-by\\\\x2duuid-$(echo "${_boot_uuid}" | sed 's/-/\\\\x2d/g').service"
  _efi_systemd_fsck_service="systemd-fsck@dev-disk-by\\\\x2duuid-$(echo "${_efi_uuid}" | sed 's/-/\\\\x2d/g').service"
  _root_systemd_fsck_service="systemd-fsck@dev-disk-by\\\\x2duuid-$(echo "${_root_uuid}" | sed 's/-/\\\\x2d/g').service"

  _swap_uuid_device="dev-disk-by\\\\x2duuid-$(echo "${_swap_uuid}" | sed 's/-/\\\\x2d/g').device"

  _log 'Setting filesystem...'

  (set -ex
    sed \
      -e "s/{{ root_blockdev_target }}/${_root_blockdev_target}/g" \
      -e "s/{{ root_systemd_fsck_service }}/${_root_systemd_fsck_service}/g" \
      -e "s/{{ root_uuid }}/${_root_uuid}/g" \
      $(dirname "$0")/../src/assets/etc/systemd/system/-.mount.tpl \
      | arch-chroot /mnt tee /etc/systemd/system/-.mount

    arch-chroot /mnt systemctl enable -- -.mount

    sed \
      -e "s/{{ boot_blockdev_target }}/${_boot_blockdev_target}/g" \
      -e "s/{{ boot_systemd_fsck_service }}/${_boot_systemd_fsck_service}/g" \
      -e "s/{{ boot_uuid }}/${_boot_uuid}/g" \
      $(dirname "$0")/../src/assets/etc/systemd/system/boot.mount.tpl \
      | arch-chroot /mnt tee /etc/systemd/system/boot.mount

    arch-chroot /mnt systemctl enable boot.mount

    sed \
      -e "s/{{ efi_blockdev_target }}/${_efi_blockdev_target}/g" \
      -e "s/{{ efi_systemd_fsck_service }}/${_efi_systemd_fsck_service}/g" \
      -e "s/{{ efi_uuid }}/${_efi_uuid}/g" \
      $(dirname "$0")/../src/assets/etc/systemd/system/efi.mount.tpl \
      | arch-chroot /mnt tee /etc/systemd/system/efi.mount

    arch-chroot /mnt systemctl enable efi.mount

    sed \
      -e "s/{{ swap_blockdev_target }}/${_efi_blockdev_target}/g" \
      -e "s/{{ swap_uuid }}/${_swap_uuid}/g" \
      -e "s/{{ swap_uuid_device }}/${_swap_uuid_device}/g" \
      $(dirname "$0")/../src/assets/etc/systemd/system/swap.service.tpl \
      | arch-chroot /mnt tee /etc/systemd/system/swap.service

    arch-chroot /mnt systemctl enable swap.service

    sed \
      -e "s/{{ swap_blockdev_target }}/${_swap_blockdev_target}/g" \
      -e "s/{{ swap_uuid }}/${_swap_uuid}/g" \
      $(dirname "$0")/../src/assets/etc/systemd/system/swap.swap.tpl \
      | arch-chroot /mnt tee /etc/systemd/system/swap.swap

    arch-chroot /mnt systemctl enable swap.swap
  ) || exit
}
