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
Options=rw,noexec,nosuid,nodev,fmask=0077,dmask=0077,shortname=mixed,utf8,errors=remount-ro

[Install]
WantedBy=local-fs.target
