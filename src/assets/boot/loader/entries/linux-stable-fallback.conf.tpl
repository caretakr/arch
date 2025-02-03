title Linux Stable (fallback)
linux /vmlinuz-linux-stable
initrd /initramfs-linux-stable-fallback.img
options cryptdevice=UUID={{ data_uuid }}:luks-{{ data_uuid }} root=/dev/mapper/luks-{{ data_uuid }}
