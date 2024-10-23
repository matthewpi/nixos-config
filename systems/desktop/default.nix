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

  # Hostname
  networking.hostName = "matthew-desktop";

  # Use my local timezone instead of UTC
  time.timeZone = "America/Edmonton";

  # Use the latest xanmod kernel.
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  # Enable the v4l2loopback kernel module.
  boot.extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];

  # https://criu.org/Linux_kernel
  # boot.kernelPatches = lib.singleton {
  #   name = "criu";
  #   patch = null;
  #   extraStructuredConfig = with lib.kernel; {
  #     #CHECKPOINT_RESTORE = yes;
  #     #NAMESPACES = yes;
  #     #UTS_NS = yes;
  #     #IPC_NS = yes;
  #     #SYSVIPC_SYSCTL = yes;
  #     #PID_NS = yes;
  #     #NET_NS = yes;
  #     #FHANDLE = yes;
  #     #EVENTFD = yes;
  #     #EPOLL = yes;

  #     #UNIX_DIAG = yes;
  #     #INET_DIAG = yes;
  #     #INET_UDP_DIAG = yes;
  #     #PACKET_DIAG = yes;
  #     #NETLINK_DIAG = yes;

  #     #NETFILTER_XT_MARK = yes;
  #     #TUN = yes;

  #     #INOTIFY_USER = yes;
  #     #FANOTIFY = yes;
  #     #MEMCG = yes;
  #     #CGROUP_DEVICE = yes;
  #     #MACVLAN = yes;
  #     #BRIDGE = yes;
  #     #BINFMT_MISC = yes;
  #     #IA32_EMULATION = yes;

  #     MEM_SOFT_DIRTY = yes;
  #     #USERFAULTFD = yes;
  #   };
  # };
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

  # Enable GNOME sysprof.
  services.sysprof.enable = true;

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
}
