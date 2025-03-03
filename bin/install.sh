#!/bin/sh

##
## Install
##

set -e

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root: exiting..."; exit
fi

if [ "$(uname)" != 'Linux' ]; then
  echo 'Only supported on Linux: exiting...'; exit 1
fi

_log() {
  printf "\n\033[1m# %s\033[0m\n\n" "$1"
}

_error() {
  printf "\n\033[31m# %s \033[0m\n\n" "$1"
}

_input() {
  printf "> \033[3m%s\033[0m: " "$1"
}

_main() {
  _log 'Please provide the following:'

  _input 'Hostname' \
    && read HOSTNAME

  if [ -z "$HOSTNAME" ]; then
    _error 'Hostname not provided: exiting...'; exit
  fi

  _input 'Storage device' \
    && read STORAGE_DEVICE

  if [ ! -b "/dev/$STORAGE_DEVICE" ]; then
    _error 'Storage device not found: exiting...'; exit
  fi

  _input 'Data password' \
    && read -s DATA_PASSWORD \
    && printf "\n"

  if [ -z "$DATA_PASSWORD" ]; then
    _error "Data password not provided: exiting..."; exit
  fi

  _input 'Data confirmation' \
    && read -s DATA_CONFIRMATION \
    && printf "\n"

  if [ "$DATA_PASSWORD" != "$DATA_CONFIRMATION" ]; then
    _error "Data password mismatch: exiting..."; exit
  fi

  _input 'User password' \
    && read -s USER_PASSWORD \
    && printf "\n"

  if [ -z "$USER_PASSWORD" ]; then
    _error "User password not provided: exiting..."; exit
  fi

  _input 'User confirmation' \
    && read -s USER_CONFIRMATION \
    && printf "\n"

  if [ "$USER_PASSWORD" != "$USER_CONFIRMATION" ]; then
    _error "User password mismatch: exiting..."; exit
  fi

  for script in $(dirname "$0")/../src/install.d/?*.sh; do
    if [ -f "$script" ]; then
      source "$script"

      _main "$@"

      unset -f _main
    fi
  done

  unset script
}

_main "@$"
