##
## User
##

_main() {
  _log 'Setting user...'

  (set -ex
    # arch-chroot /mnt chmod -v 0750 /home/caretakr

    arch-chroot /mnt useradd -m \
      -G wheel \
      -s /bin/zsh \
      caretakr

    # arch-chroot /mnt chown caretakr:caretakr /home/caretakr

    printf "${USER_PASSWORD}\n${USER_PASSWORD}" | arch-chroot /mnt passwd caretakr

    arch-chroot /mnt sudo -u caretakr \
      sh -c " \
        cd /home/caretakr \
          && git init \
          && git remote add origin https://github.com/caretakr/dotfiles.git \
          && git fetch origin \
          && git reset --hard origin/master \
          && git submodule update --init --recursive \
      "
  ) || exit 500
}
