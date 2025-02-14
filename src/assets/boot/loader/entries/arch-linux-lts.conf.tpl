title Arch Linux (LTS)
sort-key 02-arch-linux-lts
linux /vmlinuz-linux-lts
initrd /initramfs-linux-lts.img
options cryptdevice=UUID={{ data_uuid }}:luks-{{ data_uuid }} root=/dev/mapper/luks-{{ data_uuid }} rw quiet splash loglevel=3 vt.global_cursor_default=0 zswap.enabled=1 nowatchdog
