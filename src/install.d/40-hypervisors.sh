##
## Hypervisors
##

_main() {
  _log 'Setting hyprvisors...'

  (set -ex
    arch-chroot /mnt systemctl enable libvirt.service
    arch-chroot /mnt systemctl enable libvirt-guests.service

    arch-chroot /mnt systemctl enable systemd-binfmt.service
  ) || exit
}
