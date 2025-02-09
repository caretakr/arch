title Arch Linux (LTS) [fallback]
sort-key 02-arch-linux-lts-fallback
linux /vmlinuz-linux-lts
initrd /initramfs-linux-lts-fallback.img
options cryptdevice=UUID={{ data_uuid }}:luks-{{ data_uuid }} root=/dev/mapper/luks-{{ data_uuid }}
