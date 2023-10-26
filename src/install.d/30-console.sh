##
## Console
##

_main() {
  keymap='us'

  if \
    [ "$(dmidecode -s system-manufacturer)" = 'Dell Inc.' ] \
      && [ "$(dmidecode -s system-product-name)" = 'XPS 13 9310' \
  ]; then
    keymap='br-abnt2'
  fi

  _log 'Setting console...'

  (set -ex
    sed \
      -e "s/{{ keymap }}/${keymap}/g" \
      $(dirname "$0")/../src/assets/etc/vconsole.conf.tpl \
      | arch-chroot /mnt tee /etc/vconsole.conf
  ) || exit 28
}
