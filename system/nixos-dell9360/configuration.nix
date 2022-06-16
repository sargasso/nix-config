# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, callPackage, ... }:

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

  networking.hostName = "mischmasch-laptop"; # Define your hostname.
  networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.
  networking.wireless.iwd.enable = true;
  networking.networkmanager.wifi.backend = "iwd";

  # Set your time zone.
  time.timeZone = "America/Denver";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviourm
  networking.useDHCP = false;
  #networking.interfaces.wlan0.useDHCP = true;

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
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.pulseaudio.extraConfig = ''
    load-module module-switch-on-connect
  '';
  hardware.bluetooth.enable = true;

  # Trusted Users
  nix.trustedUsers = [ "root" "zystoli" ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.zystoli = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "libvirtd" "kvm" "qemu-libvirtd" "video" ];
    shell = pkgs.zsh;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    coreutils
    curl
    neovim
    pciutils
    dmidecode
    hdparm
    git
    firefox-wayland
    htop
    tmux
    zsh
    (pkgs.writeTextFile {
      name = "startsway";
      destination = "/bin/startsway";
      executable = true;
      text = ''
        #! ${pkgs.bash}/bin/bash
	## first import environment variables from the login manager
	systemctl --user import-environment
	# then start the service
	exec systemctl --user start sway.service
        '';
    })
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
	defaultSession = "sway";
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
  # services.openvpn.servers = {
  #  expressVPN = { config = '' config /root/nixos/openvpn/expressvpn-dallas.ovpn ''; };
  # };

  # Wayland
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # so that gtk works properly
    extraPackages = with pkgs; [
      swaylock
      swayidle
      wl-clipboard
      mako # notification daemon
      alacritty # Alacritty is the default terminal in the config
      dmenu # Dmenu is the default in the config but i recommend wofi since its wayland native
      kanshi # autorandr
    ];
  };

  environment = {
    etc = {
      # Put config files in /etc. Note that you also can put these in ~/.config, but then you can't manage them with NixOS anymore!
      #"sway/config".source = ./dotfiles/sway/config;
      #"xdg/waybar/config".source = ./dotfiles/waybar/config;
      #"xdg/waybar/style.css".source = ./dotfiles/waybar/style.css;
    };
  };

  systemd.user.targets.sway-session = {
    description = "Sway compositor session";
    documentation = [ "man:systemd.special(7)" ];
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
  };

  systemd.user.services.sway = {
    description = "Sway - Wayland window manager";
    documentation = [ "man:sway(5)" ];
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
    # We explicitly unset PATH here, as we want it to be set by
    # systemctl --user import-environment in startsway
    environment.PATH = lib.mkForce null;
    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.dbus}/bin/dbus-run-session ${pkgs.sway}/bin/sway --debug
      '';
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  programs.waybar.enable = true;

  systemd.user.services.kanshi = {
    description = "Kanshi output autoconfig ";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      # kanshi doesn't have an option to specifiy config file yet, so it looks
      # at .config/kanshi/config
      ExecStart = ''
        ${pkgs.kanshi}/bin/kanshi
      '';
      RestartSec = 5;
      Restart = "always";
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
      vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}

