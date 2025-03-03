[Unit]
Description=Mount for /
Before=local-fs.target
Requires={{ root_systemd_fsck_service }}
After={{ root_systemd_fsck_service }}
After={{ root_blockdev_target }}

[Mount]
What=/dev/disk/by-uuid/{{ root_uuid }}
Where=/
Type=ext4
Options=rw,errors=remount-ro

[Install]
WantedBy=local-fs.target
