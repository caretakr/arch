title Arch Linux (stable)
sort-key 01-arch-linux-stable
linux /vmlinuz-linux
initrd /initramfs-linux.img
options cryptdevice=UUID={{ data_uuid }}:luks-{{ data_uuid }} root=/dev/mapper/luks-{{ data_uuid }} rw quiet splash loglevel=3 vt.global_cursor_default=0 zswap.enabled=1 nowatchdog
