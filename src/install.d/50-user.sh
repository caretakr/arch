##
## User
##

_main() {
  _log 'Setting user...'

  (set -ex
    arch-chroot /mnt useradd -m \
      -G wheel \
      -s /bin/zsh \
      caretakr

    printf "${USER_PASSWORD}\n${USER_PASSWORD}" | arch-chroot /mnt passwd caretakr

    arch-chroot /mnt sudo -u caretakr \
      sh -c " \
        git clone \
          --bare \
          https://github.com/caretakr/dotfiles.git \
          /home/caretakr/.dotfiles \
          && git \
            --git-dir=/home/caretakr/.dotfiles \
            --work-tree=/home/caretakr \
            checkout \
            -f \
          && git \
            --git-dir=/home/caretakr/.dotfiles \
            --work-tree=/home/caretakr \
            config \
            --local \
            status.showUntrackedFiles no
      "
  ) || exit
}
