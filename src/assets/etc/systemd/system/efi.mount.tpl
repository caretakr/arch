[Unit]
Description=Mount for /efi
Before=local-fs.target
Requires={{ efi_systemd_fsck_service }}
After={{ efi_systemd_fsck_service }}
After={{ efi_blockdev_target }}
After=-.mount

[Mount]
What=/dev/disk/by-uuid/{{ efi_uuid }}
Where=/efi
Type=vfat
Options=rw,noexec,nosuid,nodev,fmask=0077,dmask=0077,shortname=mixed,utf8,errors=remount-ro

[Install]
WantedBy=local-fs.target
