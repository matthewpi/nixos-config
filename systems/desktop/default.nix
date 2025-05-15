{
  config,
  lib,
  pkgs,
  ...
}: {
  system.stateVersion = "23.05";

  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];

  programs.nix-ld.enable = true;

  # Hostname
  networking.hostName = "matthew-desktop";

  # Use my local timezone instead of UTC
  time.timeZone = "America/Edmonton";

  # Use the stable xanmod kernel.
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  boot.kernelModules = [
    "unix_diag"
    "inet_diag"
    "inet_udp_diag"
    "packet_diag"
    "netlink_diag"
    "netfilter_xt_mark"
    "tun"
    "macvlan"
    "bridge"
  ];

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

  # Enable aarch64 emulation for Nix builds
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  nix.settings.system-features = [
    "big-parallel"
    "gccarch-x86-64-v2"
    "gccarch-x86-64-v3"
    "gccarch-x86-64-v4"
    "gccarch-znver3"
    "gccarch-znver4"

    "keys"
    "kernel-module-keys"
    "secureboot"
    "pcr-keys"
    "verity-keys"
  ];

  # Configure restic to backup important directories
  services.restic.backups = {
    matthew-code = {
      # This avoids running a PreStart command that prints 20,000 snapshot entries,
      # if we ever need to re-initialize the repository, set this option to true,
      # then disable it.
      initialize = false;
      user = "matthew";
      paths = [
        "/code/matthewpi"
        "/code/nexavo"
        "/code/pterodactyl"
        "/home/matthew/.local/share/obsidian"
      ];
      exclude = [
        # Nix
        ".devenv"
        ".direnv"
        "result*"

        # Nuxt and JavaScript
        ".nuxt"
        ".output"
        ".pnpm-store"
        ".turbo"
        "node_modules"
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

  # Configure default interfaces for DHCP and IPv6 RA, alongside jumbo frames.
  systemd.network.networks."40-en" = {
    matchConfig.Name = "en*";
    linkConfig.MTUBytes = "9000";
    DHCP = "ipv4";
    networkConfig.IPv6AcceptRA = true;
    dhcpV4Config.UseDNS = false;
    dhcpV6Config.UseDNS = false;
  };

  # Disable default resolved config, we use an age encrypted one with NextDNS.
  environment.etc."systemd/resolved.conf".enable = false;

  # Override the default time servers to use DHCP instead.
  networking.timeServers = lib.mkForce [];

  # Enable XWayland.
  programs.xwayland.enable = true;

  programs.nix-required-mounts = {
    enable = true;
    allowedPatterns = {
      keys.paths = ["/var/lib/keys"];
      kernel-module-keys.paths = ["/var/lib/keys/kernel"];
      secureboot.paths = ["/var/lib/keys/secureboot"];
      pcr-keys.paths = ["/var/lib/keys/pcr"];
      verity-keys.paths = ["/var/lib/keys/verity"];
    };
  };
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/keys";
      mode = "0755";
    }
  ];

  boot.kernel.sysctl = {
    # 20-sched.conf
    "kernel.sched_cfs_bandwidth_slice_us" = 3000;
    # 20-net-timeout.conf
    # This is required due to some games being unable to reuse their TCP ports
    # if they're killed and restarted quickly - the default timeout is too large.
    "net.ipv4.tcp_fin_timeout" = 5;
    # 30-vm.conf
    # USE MAX_INT - MAPCOUNT_ELF_CORE_MARGIN.
    # see comment in include/linux/mm.h in the kernel tree.
    "vm.max_map_count" = 2147483642;
  };

  # services.ollama = {
  #   enable = true;
  #   acceleration = "rocm";
  #   rocmOverrideGfx = "11.0.0";
  # };
}
