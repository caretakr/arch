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
Type=ext4
Options=rw,nosuid,nodev,noexec,errors=remount-ro

[Install]
WantedBy=local-fs.target
