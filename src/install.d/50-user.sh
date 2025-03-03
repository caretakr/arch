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

    arch-chroot /mnt sudo -u caretakr sh -c '
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
    '
  ) || exit

  _log 'Adding temporary sudo...'

  (set -ex
    cat <<EOF | arch-chroot /mnt tee /etc/sudoers.d/90-caretakr
caretakr ALL=(ALL) NOPASSWD: ALL
EOF
  ) || exit

  _log 'Running user install...'

  (set -ex
    if [ -f /mnt/home/caretakr/.arch/install.sh ]; then
      arch-chroot /mnt chmod +x /home/caretakr/.arch/install.sh \
        && arch-chroot /mnt sudo -u caretakr /home/caretakr/.arch/install.sh
    fi
  ) || exit

  _log 'Removing temporary sudo...'

  (set -ex
    arch-chroot /mnt rm -rf /etc/sudoers.d/90-caretakr
  ) || exit
}
