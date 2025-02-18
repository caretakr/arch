title Arch (Zen)
sort-key 03-arch-zen
linux /vmlinuz-linux-zen
initrd /initramfs-linux-zen.img
options rd.luks.name={{ data_uuid }}=luks-{{ data_uuid }} rd.luks.options=discard root=/dev/mapper/luks-{{ data_uuid }} rw quiet splash loglevel=3 rd.systemd.show_status=auto rd.udev.log_level=3 vt.global_cursor_default=0 zswap.enabled=1
