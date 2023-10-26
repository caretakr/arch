[Unit]
Description=Cryptography Setup for swap
DefaultDependencies=no
After=cryptsetup-pre.target systemd-udevd-kernel.socket
Before=blockdev@dev-mapper-swap.target
Wants=blockdev@dev-mapper-swap.target
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
ExecStart=/usr/lib/systemd/systemd-cryptsetup attach 'swap' '/dev/disk/by-uuid/{{ swap_uuid }}' '/dev/urandom' 'swap,offset=2048,cipher=aes-cbc-essiv:sha256,size=256'
ExecStartPost=/usr/lib/systemd/systemd-makefs swap '/dev/mapper/swap'
ExecStop=/usr/lib/systemd/systemd-cryptsetup detach 'swap'

[Install]
WantedBy=local-fs.target
