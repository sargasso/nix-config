# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, callPackage, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Boot variables for EFI and VFIO
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      availableKernelModules = [ "amdgpu" "vfio-pci" ];
      preDeviceCommands = ''
        DEVS="0000:2f:00.0 0000:2f:00.1 0000:01:00.0"
        for DEV in $DEVS; do
          echo "vfio-pci" > /sys/bus/pci/devices/$DEV/driver_override
        done
      modprobe -i vfio-pci
      '';
    };

    kernel.sysctl = {
      # vm memory assignment
      "vm.nr_overcommit_hugepages" = 5120;
      "vm.hugetlb_shm_group" = 302;

      # disable ipv6
      "net.ipv6.conf.default.disable_ipv6" = 1;
      "net.ipv6.conf.all.disable_ipv6" = 1;
      "net.ipv6.conf.lo.disable_ipv6" = 1;
    };

    # Notes: https://alexbakker.me/post/nixos-pci-passthrough-qemu-vfio.html
    #kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "amd_iommu=on" "pcie_aspm=off" "hugepagesz=2MB" "hugepages=8192" ];
    kernelModules = [ "kvm-amd" "i2c-dev" ];
  };

  networking.hostName = "mischmasch"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "America/Denver";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviourm
  networking.useDHCP = false;
  networking.interfaces.enp42s0.useDHCP = true;
  networking.interfaces.wlp39s0.useDHCP = true;

  # Additional mounts (NFS, SMB, etc)
  fileSystems."/mnt/vol-nfs" = {
    device = "yokohama-s.stack.qonium.net:/mnt/vol-nfs/smb";
    fsType = "nfs";
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Allow Unfree and NUR (AUR equivalent)
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # OpenCL/GL/Vulkan
  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-opencl-runtime
  ];
  
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

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
     curl
     neovim
     pciutils
     dmidecode
     hdparm
     git
     firefox
     libhugetlbfs
     htop
     tmux
     zsh
     swtpm
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

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable XServer and i3 Services
  services.xserver = {
    videoDrivers = [ "amdgpu" ];
    enable = true;
    layout = "us";

    desktopManager = {
      xterm.enable = false;
    };
   
    displayManager = {
        defaultSession = "none+i3";
    };

    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
 
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3status
     ];
    };
  };

  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
    };
    libvirtd = {
      enable = true;
      qemuOvmf = true;
      qemuRunAsRoot = false;
      onBoot = "ignore";
      onShutdown = "shutdown";
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
  system.stateVersion = "21.05"; # Did you read the comment?

}

