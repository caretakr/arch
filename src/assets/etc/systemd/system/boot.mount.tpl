[Unit]
Description=Mount for /boot
Before=local-fs.target
Requires={{ boot_systemd_fsck_service }}
After={{ boot_systemd_fsck_service }}
After={{ boot_blockdev_target }}
After=-.mount

[Mount]
What=/dev/disk/by-uuid/{{ boot_uuid }}
Where=/boot
Type=vfat
Options=rw,noatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro

[Install]
WantedBy=local-fs.target
