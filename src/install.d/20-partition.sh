##
## Storage
##

_main() {
  _storage_prefix="$STORAGE_DEVICE"

  if [[ "$_storage_prefix" = nvme* ]]; then
   _storage_prefix="${_storage_prefix}p"
  fi

  EFI_PARTITION="${_storage_prefix}1"
  BOOT_PARTITION="${_storage_prefix}2"
  SWAP_PARTITION="${_storage_prefix}3"
  DATA_PARTITION="${_storage_prefix}4"

  _sectors="$((512*4))" # 4K compatible

  _efi_start="$((1*${_sectors}))"
  _efi_size="$((512*${_sectors}))"

  _boot_start="$((${_efi_start}+${_efi_size}))"
  _boot_size="$((1024*${_sectors}))"

  _swap_start="$((${_boot_start}+${_boot_size}))"
  _swap_size="$(dmidecode -t 17 | grep "Size.*GB" | awk '{s+=$2} END {print s*1024*1.5*'${_sectors}'}')"

  _data_start="$((${_swap_start}+${_swap_size}))"

  _mounts="
    /mnt/boot \
    /mnt/efi \
    /mnt
  "

  _log 'Setting storage...'

  ( set -ex
    for _mount in $_mounts; do
      if grep -q "$_mount" /proc/mounts; then
        umount "$_mount"
      fi
    done

    _data_uuid="$(blkid -s UUID -o value "/dev/${DATA_PARTITION}")"

    if [ -b "/dev/mapper/luks-${_data_uuid}" ]; then
      _log 'Closing dangled devices...'

      cryptsetup close "luks-${_data_uuid}"
    fi

    sed \
      -e "s/{{ boot_partition }}/${BOOT_PARTITION}/g" \
      -e "s/{{ boot_size }}/${_boot_size}/g" \
      -e "s/{{ boot_start }}/${_boot_start}/g" \
      -e "s/{{ data_partition }}/${DATA_PARTITION}/g" \
      -e "s/{{ data_start }}/${_data_start}/g" \
      -e "s/{{ efi_partition }}/${EFI_PARTITION}/g" \
      -e "s/{{ efi_size }}/${_efi_size}/g" \
      -e "s/{{ efi_start }}/${_efi_start}/g" \
      -e "s/{{ storage_device }}/${STORAGE_DEVICE}/g" \
      -e "s/{{ swap_partition }}/${SWAP_PARTITION}/g" \
      -e "s/{{ swap_size }}/${_swap_size}/g" \
      -e "s/{{ swap_start }}/${_swap_start}/g" \
      $(dirname "$0")/../src/assets/sfdisk.tpl \
      | sfdisk "/dev/${STORAGE_DEVICE}"

    sleep 1 # Wait a little to sync properly

    printf "$DATA_PASSWORD" | cryptsetup luksFormat \
      "/dev/${DATA_PARTITION}" --sector-size 4096 -d - \

    printf "$DATA_PASSWORD" | cryptsetup luksOpen \
      "/dev/${DATA_PARTITION}" "luks-$(blkid -s UUID -o value "/dev/${DATA_PARTITION}")" -d -

    mkfs.fat -S 4096 -F 32 "/dev/${EFI_PARTITION}"
    mkfs.fat -S 4096 -F 32 "/dev/${BOOT_PARTITION}"

    mkfs.ext2 -b 4096 -F "/dev/${SWAP_PARTITION}" 1M \
      && tune2fs -m 0 "/dev/${SWAP_PARTITION}"

    _data_uuid="$(blkid -s UUID -o value "/dev/${DATA_PARTITION}")"

    mkfs.ext4 -b 4096 -F "/dev/mapper/luks-${_data_uuid}" \
      && tune2fs -m 1 "/dev/mapper/luks-${_data_uuid}"

    mount \
      -o rw,errors=remount-ro \
      "/dev/mapper/luks-$(blkid -s UUID -o value "/dev/${DATA_PARTITION}")" /mnt

    mkdir -p /mnt/boot

    mount \
      -o rw,noexec,nosuid,nodev,fmask=0077,dmask=0077,shortname=mixed,utf8,errors=remount-ro \
      "/dev/${BOOT_PARTITION}" \
      /mnt/boot

    mkdir -p /mnt/efi

    mount \
      -o rw,noexec,nosuid,nodev,fmask=0077,dmask=0077,shortname=mixed,utf8,errors=remount-ro \
      "/dev/${EFI_PARTITION}" \
      /mnt/efi
  ) || exit
}
