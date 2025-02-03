##
## Partition
##

_main() {
  _storage_prefix="$STORAGE_DEVICE"

  if [[ "$storage_device" = nvme* ]]; then
   _storage_prefix="${storage_prefix}p"
  fi

  EFI_PARTITION="${_storage_prefix}1"
  BOOT_PARTITION="${_storage_prefix}2"
  SWAP_PARTITION="${_storage_prefix}3"
  DATA_PARTITION="${_storage_prefix}4"

  _efi_start="2048"
  _efi_size="$((1*512*2048))"

  _boot_start="$((${_efi_start}+${_efi_size}))"
  _boot_size="$((1*1536*2048))"

  _swap_start="$((${_boot_start}+${_boot_size}))"
  _swap_size="$(dmidecode -t 17 | grep "Size.*GB" | awk '{s+=$2} END {print s * 1024 * 2.5 * 2048}')"

  _data_start="$((${_swap_start}+${_swap_size}))"

  _mounts="
    /mnt/boot \
    /mnt/efi \
    /mnt
  "

  _log 'Closing dangled mounts...'

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
  ) || exit 101

  _log 'Partitioning device...'

  ( set -ex
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
  ) || exit 102

  _log 'Encrypting partitions...'

  (set -ex
    printf "$DATA_PASSWORD" | cryptsetup luksFormat --sector-size=4096 \
      "/dev/${DATA_PARTITION}" -d - \

    _data_uuid="$(blkid -s UUID -o value "/dev/${DATA_PARTITION}")"

    printf "$DATA_PASSWORD" | cryptsetup luksOpen \
      "/dev/${DATA_PARTITION}" "luks-${_data_uuid}" -d -

  ) || exit 103

  _log 'Formatting partitions...'

  (set -ex
    mkfs.fat -F 32 "/dev/${EFI_PARTITION}"
    mkfs.ext4 -f "/dev/${BOOT_PARTITION}"
    mkfs.ext2 -F "/dev/${SWAP_PARTITION}" 1M
    mkfs.ext4 -f "/dev/mapper/luks-${_data_uuid}"
  ) || exit 104

  _log 'Mounting partitions...'

  (set -ex
    mount \
      -o rw,errors=remount-ro \
      "/dev/mapper/luks-${_data_uuid}" /mnt

    mkdir -p /mnt/boot

    mount \
      -o rw,nosuid,nodev,noexec,errors=remount-ro \
      "/dev/${BOOT_PARTITION}" \
      /mnt/boot

    mount \
      -o rw,nodev,noexec,fmask=0077,dmask=0077,shortname=mixed,utf8,errors=remount-ro \
      "/dev/${BOOT_PARTITION}" \
      /mnt/efi

    umount /mnt
  ) || exit 105
}
