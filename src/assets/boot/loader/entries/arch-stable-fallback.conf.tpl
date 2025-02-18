title Arch (stable) [fallback]
sort-key 01-arch-stable-fallback
linux /vmlinuz-linux
initrd /initramfs-linux-fallback.img
options rd.luks.name={{ data_uuid }}=luks-{{ data_uuid }} rd.luks.options=discard root=/dev/mapper/luks-{{ data_uuid }}
