title Arch (Linux) [fallback]
sort-key 01-arch-linux-fallback
linux /vmlinuz-linux
initrd /initramfs-linux-fallback.img
options rd.luks.name={{ data_uuid }}=root rd.luks.options=discard root=/dev/mapper/root
