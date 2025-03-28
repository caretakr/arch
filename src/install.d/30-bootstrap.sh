##
## Bootstrap
##

_main() {
  _log 'Bootstrapping system...'

  (set -ex
    _packages=" \
      adwaita-icon-theme \
      alsa-plugins \
      alsa-utils \
      ansible \
      ansible-lint \
      ansible-language-server \
      base \
      base-devel \
      bash-language-server \
      bluez \
      bluez-utils \
      brightnessctl \
      btop \
      buildah \
      clang \
      cliphist \
      cpplint \
      dmidecode \
      dnsmasq \
      dosfstools \
      dunst \
      editorconfig-checker \
      edk2-ovmf \
      efibootmgr \
      eslint_d \
      exfatprogs \
      firewalld \
      foot \
      fscrypt \
      fwupd \
      fzf \
      gcr \
      gdb \
      gettext \
      git \
      gnome-themes-extra \
      gnupg \
      go \
      go-tools \
      gofumpt \
      gopls \
      grim \
      grml-zsh-config \
      gstreamer \
      gst-libav \
      gst-plugin-pipewire \
      gst-plugin-va \
      gst-plugins-bad \
      gst-plugins-base \
      gst-plugins-good \
      gst-plugins-ugly \
      gtk2 \
      gtk3 \
      gtk4 \
      hyprcursor \
      hypridle \
      hyprland \
      hyprlock \
      hyprpaper \
      hyprsunset \
      intel-gpu-tools \
      intel-media-sdk \
      intel-ucode \
      iptables-nft \
      iwd \
      jq \
      kanshi \
      keepassxc \
      kvantum \
      kvantum-qt5 \
      libappindicator-gtk3 \
      libfido2 \
      libnotify \
      libsecret \
      libva \
      libva-utils \
      libvirt \
      libc++ \
      linux \
      linux-firmware \
      linux-zen \
      lld \
      lldb \
      llvm \
      lua \
      luajit \
      luarocks \
      mailcap \
      man-db \
      man-pages \
      mesa \
      mesa-utils \
      neovim \
      netavark \
      nodejs \
      noto-fonts \
      noto-fonts-cjk \
      noto-fonts-emoji \
      noto-fonts-extra \
      nvm \
      openbsd-netcat \
      openssh \
      passt \
      perl-file-mimeinfo \
      pinentry \
      pipewire \
      pipewire-alsa \
      pipewire-audio \
      pipewire-jack \
      pipewire-pulse \
      playerctl \
      plymouth \
      pnpm \
      podman \
      polkit \
      polkit-gnome \
      pyright \
      python \
      qemu-full \
      qemu-user-static \
      qemu-user-static-binfmt \
      qt5-base \
      qt5-svg \
      qt5-wayland \
      qt5ct \
      qt6-base \
      qt6-svg \
      qt6-wayland \
      qt6ct \
      reflector \
      ripgrep \
      rsync \
      ruff \
      rustup \
      rust-analyzer \
      slurp \
      socat \
      sof-firmware \
      stylelint \
      sudo \
      swtpm \
      terminus-font \
      terraform \
      tmuxp \
      trash-cli \
      ttf-firacode-nerd \
      ttf-nerd-fonts-symbols \
      ttf-nerd-fonts-symbols-mono \
      udiskie \
      udisks2 \
      unarchiver \
      uv \
      vim \
      virt-manager \
      vscode-css-languageserver \
      vscode-html-languageserver \
      vscode-json-languageserver \
      vulkan-icd-loader \
      vulkan-intel \
      vulkan-tools \
      waybar \
      wireguard-tools \
      wireplumber \
      wl-clipboard \
      xdg-desktop-portal-gtk \
      xdg-desktop-portal-hyprland \
      xdg-user-dirs \
      xdg-utils \
      yamllint \
      yaml-language-server \
      zoxide \
      zsh \
      zsh-autosuggestions \
      zsh-completions \
      zsh-history-substring-search \
      zsh-syntax-highlighting \
    "

    if \
      [ "$(dmidecode -s system-manufacturer)" = 'Dell Inc.' ] \
        && [ "$(dmidecode -s system-product-name)" = 'XPS 13 9310' ]
    then
      _packages=" \
        $_packages \
        iio-sensor-proxy \
        intel-media-driver \
      "
    fi

    if \
      [ "$(dmidecode -s system-manufacturer)" = 'Apple Inc.' ] \
        && [ "$(dmidecode -s system-product-name)" = 'MacBookPro9,2' ]
    then
      _packages=" \
        $_packages \
        broadcom-wl \
        libva-intel-driver \
        vulkan-swrast \
      "
    fi

    pacstrap -K \
      /mnt \
      $_packages
  ) || exit
}
