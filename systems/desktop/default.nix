{
  config,
  lib,
  pkgs,
  ...
}: {
  system.stateVersion = "23.05";

  imports = [
    ./hardware-configuration.nix
  ];

  # Allow unfree
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  # Hostname
  networking.hostName = "matthew-desktop";

  # Use my local timezone instead of UTC
  time.timeZone = "America/Edmonton";

  # Use the xanmod kernel
  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux_xanmod_latest;

  # Enable the MEM_SOFT_DIRTY kernel option.
  # This is temporarily disabled due to it causing a kernel rebuild and not currently being required.
  # boot.kernelPatches = lib.singleton {
  #   name = "enable-mem-soft-dirty";
  #   patch = null;
  #   extraStructuredConfig = with lib.kernel; {
  #     MEM_SOFT_DIRTY = yes;
  #   };
  # };

  # Enable SSH
  services.openssh.enable = true;

  # Enable Tailscale
  services.tailscale = {
    enable = true;
    permitCertUid = "1000";
  };
  networking.firewall.trustedInterfaces = ["tailscale0"];

  # Allow passwordless sudo
  security.sudo.extraRules = [
    {
      groups = ["wheel"];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  # Editor
  environment.variables.EDITOR = lib.mkOverride 900 "nvim";

  # Packages
  environment.systemPackages = with pkgs; [
    bind
    dig
    fd
    file
    fzf
    git
    gnugrep
    (neovim.override {
      configure = {
        packages.myPlugins = with vimPlugins; {
          start = [
            vim-lastplace
            vim-nix
          ];
          opt = [];
        };

        customRC = ''
          filetype plugin indent on

          set encoding=utf-8
          set fileencoding=utf-8

          syntax on

          :set nu
        '';
      };

      viAlias = true;
      vimAlias = true;
    })
    nmap
    rclone
    sbctl
    tmux
    traceroute
    tree
    unzip
    wget
    zip
  ];

  # Configure GDM to use the same monitor configuration as the "matthew" user does
  systemd.tmpfiles.rules = [
    "L+ /run/gdm/.config/monitors.xml 0400 gdm gdm - ${config.home-manager.users.matthew.xdg.configFile."monitors.xml".source}"
  ];

  # Enable aarch64 emulation for Nix builds
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  # Configure restic to backup important directories
  services.restic.backups = {
    matthew-code = {
      initialize = true;
      user = "matthew";
      paths = [
        "/home/matthew/code/matthewpi"
        "/home/matthew/code/nexavo"
        "/home/matthew/code/pterodactyl"
        "/home/matthew/.local/share/obsidian"
      ];
      exclude = [
        ".direnv"
        "result*"
        "node_modules"
        ".output"
        ".turbo"
        ".nuxt"
      ];

      environmentFile = config.age.secrets.restic-matthew-code.path;
      repositoryFile = config.age.secrets.restic-matthew-code-repository.path;
      passwordFile = config.age.secrets.restic-matthew-code-password.path;

      timerConfig = {
        OnCalendar = "*:0/15"; # every 15 minutes
        Persistent = true;
      };
    };
  };

  # Allow loading of kernel modules at runtime.
  security.lockKernelModules = false;

  # Enable GNOME sysprof.
  services.sysprof.enable = true;

  # Allow systemd to handle coredumps.
  systemd.coredump = {
    enable = true;
    extraConfig = ''
      Storage=none
      ProcessSizeMax=0
    '';
  };
}
