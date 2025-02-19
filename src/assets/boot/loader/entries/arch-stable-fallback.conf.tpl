title Arch (stable) [fallback]
sort-key 01-arch-stable-fallback
linux /vmlinuz-linux
initrd /initramfs-linux-fallback.img
options rd.luks.name={{ data_uuid }}=root rd.luks.options=discard root=/dev/mapper/root
