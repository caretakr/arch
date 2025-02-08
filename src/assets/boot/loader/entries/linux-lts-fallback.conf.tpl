title Linux LTS (fallback)
sort-key 04
linux /vmlinuz-linux-lts
initrd /initramfs-linux-lts-fallback.img
options cryptdevice=UUID={{ data_uuid }}:luks-{{ data_uuid }} root=/dev/mapper/luks-{{ data_uuid }}
