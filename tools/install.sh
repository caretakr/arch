#!/bin/sh

##
## Install
##

set -e

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root: exiting..."; exit
fi

if [ "$(uname)" != 'Linux' ]; then
  echo 'Only supported on Linux: exiting...'; exit
fi

INSTALL_HOME="$(mktemp -d -p /var/tmp -t install-XXXXXXXX)"

_cleanup() {
  rm -rf "$INSTALL_HOME"
}

trap _cleanup INT TERM EXIT

REPO=${REPO:-caretakr/arch}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-master}

_welcome() {
    printf "\n%s" '***************************'
    printf "\n* \033[1m%s\033[0m *\n" "Arch Linux installer..."
    printf "%s\n\n" '***************************'

    printf "  This script streamlines the Arch Linux installation by first checking necessary permissions and dependencies. It ensures Git is available and installs it if missing. Next, it clones a repository with essential installation files. Once cloned, the repository's installer is executed, updating the user about each step via terminal messages.\n"
}

_log() {
  printf "\n\033[1m# %s\033[0m\n\n" "$1"
}

_error() {
  printf "\n\033[31m# %s \033[0m\n\n" "$1"
}

_main() {
  _welcome

  _log 'Fixing permissions...'

  ( set -x
    umask g-w,o-w
  ) || exit

  _log 'Checking requirements...'

  ( set -x
    (command -v "git" > /dev/null 2>&1) || {
      (pacman -S \
        --needed \
        --noconfirm \
        --ask=4 \
        git
      ) || {
        _error "Git not installed: exiting..."

        exit
      }
    }
  ) || exit

  _log 'Cloning repository...'

  ( set -x
    git clone \
      -c core.eol=lf \
      -c core.autocrlf=false \
      -c fsck.zeroPaddedFilemode=ignore \
      -c fetch.fsck.zeroPaddedFilemode=ignore \
      -c receive.fsck.zeroPaddedFilemode=ignore \
      --depth=1 \
      --branch="$BRANCH" \
      "$REMOTE" \
      "$INSTALL_HOME" || {
        [ -d "$INSTALL_HOME" ] && {
          rm -rf "$INSTALL_HOME" 2> /dev/null
        }

        exit
      }
  ) || exit

  _log 'Running install...'

  cd "$INSTALL_HOME" \
    && ./bin/install.sh
}

_main
