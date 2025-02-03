title Linux Zen (fallback)
linux /vmlinuz-linux-zen
initrd /initramfs-linux-zen-fallback.img
options cryptdevice=UUID={{ data_uuid }}:luks-{{ data_uuid }} root=/dev/mapper/luks-{{ data_uuid }}
