title Arch (Linux Zen) [fallback]
sort-key 02-arch-linux-zen-fallback
linux /vmlinuz-linux-zen
initrd /initramfs-linux-zen-fallback.img
options rd.luks.name={{ data_uuid }}=root rd.luks.options=discard root=/dev/mapper/root
