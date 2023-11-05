##
## Clock
##

_main() {
  _log 'Setting clock...'

  ( set -ex
    timedatectl set-ntp true
  ) || exit 10
}
