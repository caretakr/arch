title Linux LTS
linux /vmlinuz-linux-lts
initrd /initramfs-linux-lts.img
options cryptdevice=UUID={{ data_uuid }}:luks-{{ data_uuid }} root=/dev/mapper/luks-{{ data_uuid }} rw quiet splash loglevel=3 vt.global_cursor_default=0 nowatchdog
