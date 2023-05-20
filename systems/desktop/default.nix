{
  config,
  lib,
  pkgs,
  ...
}: {
  system.stateVersion = "23.05";

  imports = [
    ./hardware-configuration.nix
    ./secure-boot.nix
  ];

  # Hostname
  networking.hostName = "matthew-desktop";

  # Use my local timezone instead of UTC
  time.timeZone = "America/Edmonton";

  # Use the xanmod kernel
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;

  # Enable SSH
  services.openssh.enable = true;

  # Allow unfree
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

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
    (git.override {
      sendEmailSupport = true;
      withSsh = true;
      withLibsecret = !stdenv.isDarwin;
    })
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

  # Monitor configuration
  # TODO: find a way to set both the user and gdm monitor configuration
  systemd.tmpfiles.rules = [
    "L+ /run/gdm/.config/monitors.xml 0400 gdm gdm - ${pkgs.writeText "gdm-monitors.xml" ''
      <monitors version="2">
        <configuration>
          <logicalmonitor>
            <x>0</x>
            <y>0</y>
            <scale>1</scale>
            <monitor>
              <monitorspec>
                <connector>HDMI-1</connector>
                <vendor>ACR</vendor>
                <product>GN246HL</product>
                <serial>LW3AA0018533</serial>
              </monitorspec>
              <mode>
                <width>1920</width>
                <height>1080</height>
                <rate>60.000</rate>
              </mode>
            </monitor>
          </logicalmonitor>
          <logicalmonitor>
            <x>1920</x>
            <y>0</y>
            <scale>1</scale>
            <primary>yes</primary>
            <monitor>
              <monitorspec>
                <connector>DP-3</connector>
                <vendor>VSC</vendor>
                <product>XG2405</product>
                <serial>VYE204002754</serial>
              </monitorspec>
              <mode>
                <width>1920</width>
                <height>1080</height>
                <rate>144.001</rate>
              </mode>
            </monitor>
          </logicalmonitor>
        </configuration>
      </monitors>
    ''}"
  ];

  hardware = {
    amdgpu = {
      loadInInitrd = true;
      amdvlk = false;
      opencl = true;
    };

    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;

      # https://github.com/NixOS/nixpkgs/pull/225325
      package = lib.mkForce pkgs.mesa.drivers;
      package32 = lib.mkForce pkgs.pkgsi686Linux.mesa.drivers;
    };
  };

  # Enable aarch64 emulation for Nix builds
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  # Set the RTC to local-time to prevent it from breaking time in Windows
  time.hardwareClockInLocalTime = true;

  # Configure restic to backup important directories
  services.restic.backups = {
    matthew-code = {
      initialize = true;
      user = "matthew";
      paths = [
        "/home/matthew/code/matthewpi"
        "/home/matthew/code/pterodactyl"
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
}
