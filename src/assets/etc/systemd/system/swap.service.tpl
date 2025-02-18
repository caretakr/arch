[Unit]
Description=Cryptography Setup for swap
DefaultDependencies=no
After=cryptsetup-pre.target systemd-udevd-kernel.socket
Before={{ swap_blockdev_target }}
Wants={{ swap_blockdev_target }}
IgnoreOnIsolate=true
Conflicts=umount.target
Before=umount.target
Before=cryptsetup.target
After=systemd-random-seed.service
BindsTo={{ swap_uuid_device }}
After={{ swap_uuid_device }}

[Service]
Type=oneshot
RemainAfterExit=yes
TimeoutSec=infinity
KeyringMode=shared
OOMScoreAdjust=500
ExecStart=/usr/lib/systemd/systemd-cryptsetup attach 'luks-{{ swap_uuid }}' '/dev/disk/by-uuid/{{ swap_uuid }}' '/dev/urandom' 'swap,offset=2048,cipher=aes-xts-plain64,size=512,sector-size=4096'
ExecStartPost=/usr/lib/systemd/systemd-makefs swap '/dev/mapper/luks-{{ swap_uuid }}'
ExecStop=/usr/lib/systemd/systemd-cryptsetup detach 'luks-{{ swap_uuid }}'

[Install]
WantedBy=local-fs.target
