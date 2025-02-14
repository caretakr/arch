title Arch Linux (Zen)
sort-key 03-arch-linux-zen
linux /vmlinuz-linux-zen
initrd /initramfs-linux-zen.img
options cryptdevice=UUID={{ data_uuid }}:luks-{{ data_uuid }} root=/dev/mapper/luks-{{ data_uuid }} rw quiet splash loglevel=3 vt.global_cursor_default=0 zswap.enabled=1 nowatchdog
