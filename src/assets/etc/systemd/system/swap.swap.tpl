[Unit]
Description=Swap for /dev/mapper/luks-{{ swap_uuid }}
Requires=swap.service
After={{ swap_blockdev_target }}
After=swap.service

[Swap]
What=/dev/mapper/luks-{{ swap_uuid }}

[Install]
WantedBy=swap.target
