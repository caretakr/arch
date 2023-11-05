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
    && read hostname

  if [ -z "$hostname" ]; then
    _error 'Hostname not provided: exiting...'; exit
  fi

  _input 'Storage device' \
    && read storage_device

  if [ ! -b "/dev/$storage_device" ]; then
    _error 'Storage device not found: exiting...'; exit
  fi

  _input 'Data password' \
    && read -s data_password \
    && printf "\n"

  if [ -z "$data_password" ]; then
    _error "Data password not provided: exiting..."; exit
  fi

  _input 'Data confirmation' \
    && read -s data_confirmation \
    && printf "\n"

  if [ "$data_password" != "$data_confirmation" ]; then
    _error "Data password mismatch: exiting..."; exit
  fi

  _input 'User password' \
    && read -s user_password \
    && printf "\n"

  if [ -z "$user_password" ]; then
    _error "User password not provided: exiting..."; exit
  fi

  _input 'User confirmation' \
    && read -s user_confirmation \
    && printf "\n"

  if [ "$user_password" != "$user_confirmation" ]; then
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
