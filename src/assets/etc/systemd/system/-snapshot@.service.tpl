[Unit]
Description={{ period }} snapshot using "%i" profile

[Service]
Type=oneshot
EnvironmentFile=/etc/snapshot/{{ period }}.conf
ExecStart=/opt/caretakr/snapshot/bin/snapshot.sh -d $DEVICE -s $SUBVOLUME -r {{ retention }} -t {{ period }}
