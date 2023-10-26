[Unit]
Description=Mount for /root
Before=local-fs.target
After={{ root_blockdev_target }}
After=-.mount

[Mount]
What=/dev/disk/by-uuid/{{ root_uuid }}
Where=/root
Type=btrfs
Options=rw,noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,commit=60,subvol=/root@live

[Install]
WantedBy=local-fs.target
