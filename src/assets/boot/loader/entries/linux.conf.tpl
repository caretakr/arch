title Linux
sort-key 01
linux /vmlinuz-linux
initrd /initramfs-linux.img
options cryptdevice=UUID={{ data_uuid }}:luks-{{ data_uuid }} root=/dev/mapper/luks-{{ data_uuid }} rw quiet splash loglevel=3 vt.global_cursor_default=0 nowatchdog
