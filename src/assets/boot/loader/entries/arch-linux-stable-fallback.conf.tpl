title Arch (stable) [fallback]
sort-key 01-arch-stable-fallback
linux /vmlinuz-linux
initrd /initramfs-linux-fallback.img
options rd.luks.uuid={{ data_uuid }} root=UUID={{ data_uuid }}
