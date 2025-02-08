##
## Boot
##

_main() {
  _data_uuid="$(blkid -s UUID -o value "/dev/${DATA_PARTITION}")"

  _arch_version="$(date +%Y.%m).01"
  _grml_version="2024.12"

  _rescue_workdir="$(mktemp -d -t /var/tmp/rescue-XXXXXXXX)" \
    && mkdir -p "/mnt$(dirname "$_rescue_workdir")" \
    && mv "$_rescue_workdir" "/mnt$_rescue_workdir" \
    && ln -s "/mnt$_rescue_workdir" "$_rescue_workdir"

  _log 'Setting boot...'

  (set -ex
    arch-chroot /mnt bootctl --esp-path=/efi --boot-path=/boot install

    arch-chroot /mnt tee /boot/loader/loader.conf \
      < $(dirname "$0")/../src/assets/boot/loader/loader.conf

    sed \
      -e "s/{{ data_uuid }}/${_data_uuid}/g" \
      $(dirname "$0")/../src/assets/boot/loader/entries/linux.conf.tpl \
      | arch-chroot /mnt tee /boot/loader/entries/linux.conf

    sed \
      -e "s/{{ data_uuid }}/${_data_uuid}/g" \
      $(dirname "$0")/../src/assets/boot/loader/entries/linux-fallback.conf.tpl \
      | arch-chroot /mnt tee /boot/loader/entries/linux-fallback.conf

    sed \
      -e "s/{{ data_uuid }}/${_data_uuid}/g" \
      $(dirname "$0")/../src/assets/boot/loader/entries/linux-lts.conf.tpl \
      | arch-chroot /mnt tee /boot/loader/entries/linux-lts.conf

    sed \
      -e "s/{{ data_uuid }}/${_data_uuid}/g" \
      $(dirname "$0")/../src/assets/boot/loader/entries/linux-lts-fallback.conf.tpl \
      | arch-chroot /mnt tee /boot/loader/entries/linux-lts-fallback.conf

    sed \
      -e "s/{{ data_uuid }}/${_data_uuid}/g" \
      $(dirname "$0")/../src/assets/boot/loader/entries/linux-zen.conf.tpl \
      | arch-chroot /mnt tee /boot/loader/entries/linux-zen.conf

    sed \
      -e "s/{{ data_uuid }}/${_data_uuid}/g" \
      $(dirname "$0")/../src/assets/boot/loader/entries/linux-zen-fallback.conf.tpl \
      | arch-chroot /mnt tee /boot/loader/entries/linux-zen-fallback.conf

    arch-chroot /mnt setterm -cursor on >> /etc/issue

    arch-chroot /mnt tee /etc/sysctl.d/20-quiet.conf \
      < $(dirname "$0")/../src/assets/etc/sysctl.d/20-quiet.conf

    mkdir -p /mnt/etc/systemd/system/getty@tty7.service.d

    arch-chroot /mnt tee /etc/systemd/system/getty@tty7.service.d/override.conf \
      < $(dirname "$0")/../src/assets/etc/systemd/system/getty@tty7.service.d/override.conf

    arch-chroot /mnt systemctl enable getty@tty7.service \
      && arch-chroot /mnt systemctl disable getty@tty1.service
  ) || exit 900

  _log 'Setting rescues...'

  (set -ex
    mkdir -p "$_rescue_workdir/arch" \
      cd "$_rescue_workdir/arch"

    curl -fsSL \
      -o "archlinux-${_arch_version}-x86_64.iso" \
      "https://geo.mirror.pkgbuild.com/iso/${_arch_version}/archlinux-${_arch_version}-x86_64.iso"

    bsdtar xf "archlinux-${_arch_version}-x86_64.iso" \
      "arch/boot/x86_64/initramfs-linux.img" \
      "arch/boot/x86_64/vmlinuz-linux" \
      "arch/x86_64/airootfs.sfs"

    install -d /boot/arch

    install arch/boot/x86_64/initramfs-linux.img /boot/arch/initramfs-linux.img
    install arch/boot/x86_64/vmlinuz-linux /boot/arch/vmlinuz-linux
    install arch/x86_64/airootfs.sfs /boot/arch/airootfs.sfs

    arch-chroot /mnt tee /boot/loader/entries/arch.conf \
      < $(dirname "$0")/../src/assets/boot/loader/entries/arch.conf

    mkdir -p "$_rescue_workdir/grml" \
      cd "$_rescue_workdir/grml"

    curl -fsSL \
      -o "grml64-small_${_grml_version}.iso" \
      "https://download.grml.org/grml64-small_${_grml_version}.iso"

    bsdtar xf "grml64-small_${_grml_version}.iso" \
      boot/grml64small/vmlinuz \
      boot/grml64small/initrd.img \
      live/grml64-small/grml64-small.squashfs

    install -d /boot/grml

    install boot/grml64small/vmlinuz /boot/grml/vmlinuz
    install boot/grml64small/initrd.img /boot/grml/initrd.img
    install live/grml64-small/grml64-small.squashfs /boot/grml/grml64-small.squashfs

    arch-chroot /mnt tee /boot/loader/entries/grml.conf \
      < $(dirname "$0")/../src/assets/boot/loader/entries/grml.conf
  ) || exit 901

  _log 'Setting silent boot...'

  (set -ex
    arch-chroot /mnt setterm -cursor on >> /etc/issue

    arch-chroot /mnt tee /etc/sysctl.d/20-quiet.conf \
      < $(dirname "$0")/../src/assets/etc/sysctl.d/20-quiet.conf

    mkdir -p /mnt/etc/systemd/system/getty@tty7.service.d

    arch-chroot /mnt tee /etc/systemd/system/getty@tty7.service.d/override.conf \
      < $(dirname "$0")/../src/assets/etc/systemd/system/getty@tty7.service.d/override.conf

    arch-chroot /mnt systemctl enable getty@tty7.service \
      && arch-chroot /mnt systemctl disable getty@tty1.service
  ) || exit 902
}
