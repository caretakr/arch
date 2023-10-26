##
## Partition
##

_main() {
  storage_prefix="$storage_device"

  if [[ "$storage_device" = nvme* ]]; then
    storage_prefix="${storage_prefix}p"
  fi

  boot_partition="${storage_prefix}1"
  swap_partition="${storage_prefix}2"
  data_partition="${storage_prefix}3"

  boot_start="2048"
  boot_size="$((1*1024*2048))"

  swap_start="$(($boot_start+$boot_size))"
  swap_size="$(dmidecode -t 17 | grep "Size.*GB" | awk '{s+=$2} END {print s * 1024 * 2 * 2048}')"

  data_start="$(($swap_start+$swap_size))"

  subvolumes="
    - \
    home/caretakr \
    root \
    var \
  "
  mounts="
    /mnt/boot \
  "

  for subvolume in $subvolumes; do
    if [ "$subvolume" = "-" ]; then
      continue
    fi

    mounts="
      ${mounts} \
      /mnt/${subvolume} \
    "
  done

  mounts="
    ${mounts} \
    /mnt \
  "

  _log 'Closing dangled mounts...'

  ( set -ex
    for mount in $mounts; do
      if cat /proc/mounts | grep "$mount" >/dev/null; then
        umount "$mount"
      fi
    done

    if [ -b /dev/mapper/root ]; then
      _log 'Closing dangled devices...'

      cryptsetup close root
    fi
  ) || exit 11

  _log 'Partitioning device...'

  ( set -ex
    sed \
      -e "s/{{ storage_device }}/${storage_device}/g" \
      -e "s/{{ boot_partition }}/${boot_partition}/g" \
      -e "s/{{ boot_start }}/${boot_start}/g" \
      -e "s/{{ boot_size }}/${boot_size}/g" \
      -e "s/{{ swap_partition }}/${swap_partition}/g" \
      -e "s/{{ swap_start }}/${swap_start}/g" \
      -e "s/{{ swap_size }}/${swap_size}/g" \
      -e "s/{{ data_partition }}/${data_partition}/g" \
      -e "s/{{ data_start }}/${data_start}/g" \
      $(dirname "$0")/../src/assets/sfdisk.tpl \
      | sfdisk "/dev/${storage_device}"

    sleep 1
  ) || exit 12

  _log 'Encrypting partitions...'

  (set -ex
    printf "$data_password" | cryptsetup luksFormat \
      "/dev/${data_partition}" -d - \

    printf "$data_password" | cryptsetup luksOpen \
      "/dev/${data_partition}" root -d -
  ) || exit 13

  _log 'Formatting partitions...'

  (set -ex
    mkfs.fat -F 32 "/dev/${boot_partition}"
    mkfs.ext2 -F "/dev/${swap_partition}" 1M
    mkfs.btrfs -f /dev/mapper/root
  ) || exit 14

  _log 'Mounting partitions...'

  (set -ex
    mount /dev/mapper/root /mnt
    
    for subvolume in $subvolumes; do
      mkdir -p "/mnt/${subvolume}@snapshots"

      btrfs subvolume create "/mnt/${subvolume}@live"
    done

    umount /mnt
  ) || exit 15

  _log 'Mounting subvolumes...'

  (set -ex
    mount \
      -o rw,noatime,commit=60,compress=zstd:3,subvol=-@live \
      /dev/mapper/root \
      /mnt

    mkdir -p /mnt/boot

    mount \
      -o rw,noatime,fmask=0077,dmask=0077,codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro \
      "/dev/${boot_partition}" \
      /mnt/boot

    for subvolume in $subvolumes; do
      if [ "$subvolume" = '-' ]; then
        continue
      fi

      mkdir -p "/mnt/${subvolume}"

      mount -o \
        "rw,noatime,commit=60,compress=zstd:3,subvol=${subvolume}@live" \
        /dev/mapper/root \
        "/mnt/${subvolume}"
    done
  ) || exit 16
}
