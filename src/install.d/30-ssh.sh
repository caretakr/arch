##
## SSH
##

_main() {
  _log 'Setting SSH...'

  (set -ex
    arch-chroot /mnt tee /etc/ssh/sshd_config.d/20-force-publickey-auth.conf \
      < $(dirname "$0")/../src/assets/etc/ssh/sshd_config.d/20-force-publickey.conf

    arch-chroot /mnt tee /etc/ssh/sshd_config.d/20-deny-root.conf \
      < $(dirname "$0")/../src/assets/etc/ssh/sshd_config.d/20-deny-root.conf

    arch-chroot /mnt systemctl enable sshd.service
  ) || exit 45
}
