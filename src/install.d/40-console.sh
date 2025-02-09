##
## Console
##

_main() {
  _keymap='us'
  _font='ter-116n'

  if \
    [ "$(dmidecode -s system-manufacturer)" = 'Dell Inc.' ] \
      && [ "$(dmidecode -s system-product-name)" = 'XPS 13 9310' \
  ]; then
    _keymap='br-abnt2'
    _font='ter-124n'
  fi

  _log 'Setting console...'

  (set -ex
    sed \
      -e "s/{{ keymap }}/${_keymap}/g" \
      -e "s/{{ font }}/${_font}/g" \
      $(dirname "$0")/../src/assets/etc/vconsole.conf.tpl \
      | arch-chroot /mnt tee /etc/vconsole.conf
  ) || exit 402
}
