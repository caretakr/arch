title Arch (Linux Zen)
sort-key 02-arch-linux-zen
linux /vmlinuz-linux-zen
initrd /initramfs-linux-zen.img
options rd.luks.name={{ data_uuid }}=root rd.luks.options=discard root=/dev/mapper/root rw quiet splash loglevel=3 rd.systemd.show_status=auto rd.udev.log_level=3 vt.global_cursor_default=0 zswap.enabled=1
