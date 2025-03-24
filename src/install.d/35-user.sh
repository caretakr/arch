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

  _log 'Installing Yay...'

  (set -ex
    arch-chroot /mnt sudo -u caretakr sh -c '
      git clone https://aur.archlinux.org/yay-bin.git \
        /home/caretakr/.yay \
        && cd /home/caretakr/.yay \
        && makepkg -si --needed --noconfirm \
        && yay -Y --gendb
    '
  ) || exit

  rm -rf /mnt/home/caretakr/.yay

  _log 'Installing user packages...'

  (set -ex
    _packages=" \
      dockerfile-language-server \
      downgrade \
      golangci-lint \
      librewolf-bin \
      prettierd \
      rose-pine-cursor \
      rose-pine-hyprcursor \
      tmux-plugin-manager \
      vtsls \
      zsh-theme-powerlevel10k-git \
    "

    arch-chroot /mnt sudo -u caretakr yay -S \
      --needed \
      --noconfirm \
      --ask=4 \
      $_packages
  ) || exit

  _log 'Removing temporary sudo...'

  (set -ex
    arch-chroot /mnt rm -rf /etc/sudoers.d/90-caretakr
  ) || exit

  _log 'Setting permanent sudo...'

  (set -ex
    arch-chroot /mnt tee /etc/sudoers.d/20-caretakr \
      < $(dirname "$0")/../src/assets/etc/sudoers.d/20-caretakr
  ) || exit
}
