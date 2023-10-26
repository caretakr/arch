title Arch
linux /vmlinuz-linux
initrd /initramfs-linux.img
options cryptdevice=UUID={{ data_uuid }}:root root=/dev/mapper/root rootflags=subvol=-@live rw quiet splash loglevel=3 vt.global_cursor_default=0
