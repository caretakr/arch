title Linux Zen
sort-key 05
linux /vmlinuz-linux-zen
initrd /initramfs-linux-zen.img
options cryptdevice=UUID={{ data_uuid }}:luks-{{ data_uuid }} root=/dev/mapper/luks-{{ data_uuid }} rw quiet splash loglevel=3 vt.global_cursor_default=0 nowatchdog
