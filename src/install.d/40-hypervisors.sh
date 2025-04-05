##
## Hypervisors
##

_main() {
  _log 'Setting hyprvisors...'

  (set -ex
    for driver in \
      qemu \
      network \
      nodedev \
      nwfilter \
      secret \
      storage
    do
      arch-chroot /mnt systemctl enable virt${driver}d{,-ro,-admin}.socket
    done

    arch-chroot /mnt systemctl enable systemd-binfmt.service
  ) || exit
}
