title Arch (Zen) [fallback]
sort-key 03-arch-zen-fallback
linux /vmlinuz-linux-zen
initrd /initramfs-linux-zen-fallback.img
options rd.luks.uuid={{ data_uuid }} root=UUID={{ data_uuid }}
