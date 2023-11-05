##
## Snapshot
##

_main() {
  device="$(blkid -o value -s UUID /dev/mapper/root)"

  profiles="
    - \
    home-caretakr \
    root \
    var \
  "

  _log 'Setting snapshots...'

  (set -ex
    mkdir -p /opt/caretakr/snapshot

    git clone https://github.com/caretakr/snapshot.git \
      /opt/caretakr/snapshot

    arch-chroot /mnt mkdir -p /etc/snapshot

    for profile in $profiles; do
      case "$profile" in
        -) subvolume="-" ;;
        home-caretakr) subvolume="home/caretakr" ;;
        root) subvolume="root" ;;
        var) subvolume="var" ;;
      esac

      sed \
        -e "s|{{ device }}|${device}|g" \
        -e "s|{{ subvolume }}|${subvolume}|g" \
        $(dirname "$0")/../src/assets/etc/snapshot/profile.conf.tpl \
        | arch-chroot /mnt tee /etc/snapshot/${profile}.conf
    done

    for period in \
      hourly \
      daily \
      weekly \
    ; do
      case "$period" in
        hourly) 
          retention=24
          timer='*-*-* *:00:00'

          ;;
        daily)
          retention=7
          timer='*-*-* 21:00:00'
          
          ;;
        weekly)
          retention=4
          timer='Sun *-*-* 21:00:00'
          
          ;;
      esac
      
      sed \
        -e "s/{{ period }}/${period}/g" \
        -e "s/{{ tag }}/${retention}/g" \
        $(dirname "$0")/../src/assets/etc/systemd/system/-snapshot@.service.tpl \
        | arch-chroot /mnt tee /etc/systemd/system/${period}-snapshot@.service

      sed \
        -e "s/{{ period }}/${period}/g" \
        -e "s/{{ timer }}/${timer}/g" \
        $(dirname "$0")/../src/assets/etc/systemd/system/-snapshot@.timer.tpl \
        | arch-chroot /mnt tee /etc/systemd/system/${period}-snapshot@.timer

      for profile in $profiles; do
        arch-chroot /mnt systemctl enable "${period}-snapshot@${profile}.timer"
      done
    done
  ) || exit 44
}
