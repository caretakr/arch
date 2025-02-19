title Arch (Zen) [fallback]
sort-key 03-arch-zen-fallback
linux /vmlinuz-linux-zen
initrd /initramfs-linux-zen-fallback.img
options rd.luks.name={{ data_uuid }}=root rd.luks.options=discard root=/dev/mapper/root
