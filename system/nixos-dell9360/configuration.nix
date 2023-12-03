# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, callPackage, ... }:

let
  # bash script to let dbus know about important env variables and
  # propagate them to relevent services run at the end of sway config
  # see
  # https://github.com/emersion/xdg-desktop-portal-wlr/wiki/"It-doesn't-work"-Troubleshooting-Checklist
  # note: this is pretty much the same as  /etc/sway/config.d/nixos.conf but also restarts  
  # some user services to make sure they have the correct environment variables
  #dbus-sway-environment = pkgs.writeTextFile {
  #  name = "dbus-sway-environment";
  #  destination = "/bin/dbus-sway-environment";
  #  executable = true;
  #
  #  text = ''
  #dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
  #systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
  #systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
  #systemctl --user mask xdg-desktop-portal-gnome
  #    '';
  #};

  # currently, there is some friction between sway and gtk:
  # https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland
  # the suggested way to set gtk settings is with gsettings
  # for gsettings to work, we need to tell it where the schemas are
  # using the XDG_DATA_DIR environment variable
  # run at the end of sway config
  #configure-gtk = pkgs.writeTextFile {
  #    name = "configure-gtk";
  #    destination = "/bin/configure-gtk";
  #    executable = true;
  #    text = let
  #      schema = pkgs.gsettings-desktop-schemas;
  #      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
  #    in ''
  #      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
  #      gnome_schema=org.gnome.desktop.interface
  #      gsettings set $gnome_schema gtk-theme 'Dracula'
  #      '';
  #};

in
{
  imports =
    [ # Include the results of the hardware scan.
      <nixos-hardware/dell/xps/13-9360>
      ./hardware-configuration.nix
    ];

  # Boot variables for EFI and VFIO
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernel.sysctl = {
      "net.ipv6.conf.default.disable_ipv6" = 1;
      "net.ipv6.conf.all.disable_ipv6" = 1;
      "net.ipv6.conf.lo.disable_ipv6" = 1;
    };
    kernelModules = [ "kvm-intel" ];
  };

  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;
  hardware.ledger.enable = true;

  networking = {
    useDHCP = false;
    hostName = "mischmasch-laptop"; # Define your hostname.
    networkmanager.wifi.backend = "iwd";
    wireless = {
      enable = false;
      iwd.enable = true; # enable iwd but not wpa_supp
    };
  };

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Allow Unfree and NUR (AUR equivalent)
  nixpkgs.config.allowUnfree = true;

  # Overload Nix pkgmgr default options.
  nix.extraOptions = ''
    binary-caches-parallel-connections = 3
    connect-timeout = 5
  '';

  # Garbage collection automatic
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.pulseaudio.extraConfig = ''
    load-module module-switch-on-connect
  '';
  hardware.bluetooth.enable = true;

  # Trusted Users
  nix.settings.trusted-users = [ "root" "zystoli" ];

  # USB
  # groups.plugdev = {};

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.zystoli = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "libvirtd" "kvm" "qemu-libvirtd" "video" "audio" "netdev" "bluetooth" "networkmanager" "adbusers" "plugdev" ];
    shell = pkgs.zsh;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    coreutils
    gnumake
    lm_sensors
    curl
    neovim
    pciutils
    usbutils
    dmidecode
    hdparm
    git
    htop
    tmux
    zsh
    #configure-gtk
    wayland
    xdg-utils # for opening default programs when clicking links
    glib # gsettings
    gnome3.adwaita-icon-theme  # default gnome cursors
  ];

  environment.pathsToLink = [ "/libexec" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.zsh = {
    enable = true;
    shellAliases = {
      vim = "nvim";
    };
    enableCompletion = true;
    autosuggestions.enable = true;
    promptInit = "";
  };

  # Android ADB and tools
  programs.adb.enable = true;

  # List services that you want to enable:
  #
  services.fwupd.enable = true;
  services.thermald.enable = true;
  services.printing.enable = true;
  services.openssh.enable = true;
  services.dbus.enable = true;
  services.acpid.enable = true;
  services.upower.enable = true;
  services.xserver = {
    enable = true;
    layout = "us";

    # Touch inputs
    libinput.enable = true;

    desktopManager = {
      gnome.enable = true;
      xterm.enable = false;
    };
   
    displayManager = {
        lightdm.enable = false;
	defaultSession = "hyprland";
	gdm.enable = true;
	gdm.debug = true;
	gdm.wayland = true;
    };
  };
  services.gnome = {
    gnome-keyring.enable = true;
    sushi.enable = true;
    gnome-user-share.enable = true;
    core-shell.enable = true;
  };

  services.resolved = {
    enable = true;
  };

  programs.hyprland.enable = true;

  # Pipewire Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Xdg Dbus for Wayland
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };

  environment = {
    etc = {
      # Put config files in /etc. Note that you also can put these in ~/.config, but then you can't manage them with NixOS anymore!
      #"sway/config".source = ./dotfiles/sway/config;
      #"xdg/waybar/config".source = ./dotfiles/waybar/config;
      #"xdg/waybar/style.css".source = ./dotfiles/waybar/style.css;
    };
  };

  # Desktop Manager
  programs.light.enable = true;

  # Accelerated Video Playback
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      #vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # Container Runtime
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
    };
    libvirtd = {
      enable = true;
      onBoot = "ignore";
      onShutdown = "shutdown";
      qemu = {
        ovmf.enable = true;
        runAsRoot = false;
      };
    };
  };

  # Firewall
  networking.nftables = {
    enable = false;
  };

  #networking.firewall = {
  #  allowedTCPPorts = [ 22 ];
  #};

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}

