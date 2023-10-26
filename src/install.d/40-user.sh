##
## User
##

_main() {
  _log 'Setting user...'

  (set -ex
    arch-chroot /mnt chmod -v 0750 /home/caretakr

    arch-chroot /mnt useradd -m \
      -G wheel \
      -s /bin/zsh \
      caretakr

    arch-chroot /mnt chown caretakr:caretakr /home/caretakr

    printf "${user_password}\n${user_password}" | arch-chroot /mnt passwd caretakr

    arch-chroot /mnt sudo -u caretakr \
      sh -c "git clone https://github.com/caretakr/dotfiles.git /home/caretakr"
  ) || exit 48
}
