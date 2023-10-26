[Unit]
Description=Mount for /
Before=local-fs.target
After={{ root_blockdev_target }}

[Mount]
What=/dev/disk/by-uuid/{{ root_uuid }}
Where=/
Type=btrfs
Options=rw,noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,commit=60,subvol=/-@live

[Install]
WantedBy=local-fs.target
