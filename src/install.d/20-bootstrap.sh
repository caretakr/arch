##
## Bootstrap
##

_main() {
  _log 'Bootstrapping system...'

  (set -ex
    pacstrap -K /mnt \
      base \
      linux \
      linux-firmware
  ) || exit 17 
}
