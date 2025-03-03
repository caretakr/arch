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
            status.showUntrackedFiles no \
      "
  ) || exit

  _log 'Adding temporary sudo...'

  (set -ex
    cat <<EOF | arch-chroot /mnt tee /etc/sudoers.d/90-caretakr
caretakr ALL=(ALL) NOPASSWD: ALL
EOF
  ) || exit

  _log 'Running install scripts...'

  (set -ex
    arch-chroot /mnt sudo -u caretakr sh -c " \
      if [ -d /home/caretakr/.arch/install.d ]; then \
        for script in /home/caretakr/.arch/install.d/?*.sh; do \
          if [ -f "$script" ]; then \
            source "$script" \
              && _main "$@" ; \
            unset -f _main \
          ; fi \
        ; done \
      ; fi \
    "
  )

  _log 'Removing temporary sudo...'

  (set -ex
    arch-chroot /mnt rm -rf /etc/sudoers.d/90-caretakr
  ) || exit
}
