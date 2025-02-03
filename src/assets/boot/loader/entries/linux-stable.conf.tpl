title Linux Stable
linux /vmlinuz-linux-stable
initrd /initramfs-linux-stable.img
options cryptdevice=UUID={{ data_uuid }}:luks-{{ data_uuid }} root=/dev/mapper/luks-{{ data_uuid }} rw quiet splash loglevel=3 vt.global_cursor_default=0 nowatchdog
