title Linux (fallback)
sort-key 02
linux /vmlinuz-linux
initrd /initramfs-linux-fallback.img
options cryptdevice=UUID={{ data_uuid }}:luks-{{ data_uuid }} root=/dev/mapper/luks-{{ data_uuid }}
