[Unit]
Description={{ period }} snapshot using "%i" profile

[Timer]
OnCalendar={{ timer }}
Persistent=true
Unit={{ period }}-snapshot@%i.service

[Install]
WantedBy=timers.target
