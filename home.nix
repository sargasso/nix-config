{ config, lib, pkgs, ... }:

let

  # Normal Packages
  packages = with pkgs; [

    # utilities
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

    # xutils
    rofi

    # chat
    discord
    element-desktop
    irssi

    # term
    alacritty
    starship
    ion
    tmux
    tmux-cssh
    nerdfonts

    # misc
    chromium
    neofetch
    arandr
    ipmitool
    exa
    ddccontrol
    hwloc
    unzip
    wget
    speedtest-cli
    nodejs
    appimage-run
    feh
    vlc
    exif
    imagemagick

    # python
    python38Full
    python38Packages.virtualenv

    # kubernetes
    kubectl
    kubernetes-helm
    stern
    lens

    # db
    sqlite
  ];

in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  imports = builtins.map (x: ./modules + ("/" + x)) (builtins.attrNames (builtins.readDir ./modules));

  nixpkgs = {
    config = import ./config.nix;
  };

  home = {
    username = "zystoli";
    homeDirectory = "/home/zystoli";
    sessionVariables = {
      EDITOR = "nvim";
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
  home.stateVersion = "22.05";
}
