{ config, lib, pkgs, ... }:

let
  # Package map used below
  packages = with pkgs; [
    # fonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    mplus-outline-fonts.githubRelease
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })

    # wayland
    wl-clipboard
    grim
    dracula-theme
    mako
    wdisplays
    imv

    # utilities
    alacritty
    firefox-wayland
    bitwarden
    bitwarden-cli
    cachix
    github-cli
    htop
    libreoffice
    ngrok
    pavucontrol
    ripgrep
    virt-manager
    docker-buildx
    buildah
    bind
    yq
    jq
    khal
    signify

    # xutils
    rofi
    redshift

    # Hypr
    hyprpaper
    eww-wayland
    wofi

    # chat
    discord
    irssi

    # term
    alacritty
    starship
    ion
    tmux
    tmux-cssh

    # misc
    chromium
    neofetch
    arandr
    ipmitool
    eza
    ddccontrol
    hwloc
    unzip
    wget
    speedtest-cli
    nodejs
    yarn
    yarn2nix
    appimage-run
    feh
    vlc
    exif
    imagemagick
    mpd
    nmap
    libarchive
    jmtpfs
    pkg-config

    # python
    python310Full
    python310Packages.virtualenv

    # kubernetes
    kubectl
    kubernetes-helm
    krew
    k9s
    stern
    fluxcd
    argocd

    # db
    sqlite

    # editors
    vscode
  ];

in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  imports = builtins.map (x: ./modules + ("/" + x)) (builtins.attrNames (builtins.readDir ./modules));

  nixpkgs = {
    config = import ./config.nix;
  };

  fonts.fontconfig.enable = true;

  home = {
    username = "zystoli";
    homeDirectory = "/home/zystoli";
    sessionVariables = {
      EDITOR = "nvim";
      MOZ_ENABLE_WAYLAND = 1;
      NIXOS_OZONE_WL = "1";
      XDG_CURRENT_DESKTOP = "hyprland"; 
    };
    packages = packages;
  };

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      desktop = "\$HOME";
      documents = "\$HOME/Documents";
      download = "\$HOME/Downloads";
      music = "\$HOME/Music";
      pictures = "\$HOME/Pictures";
      videos = "\$HOME/Videos";
    };
    mime.enable = true;
  };

  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";
}
