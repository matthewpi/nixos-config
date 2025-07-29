{
  flake.nixosModules.desktop = {
    lib,
    pkgs,
    ...
  }: {
    imports = [
      ./bluetooth.nix
      ./corectrl.nix
      ./dconf.nix
      ./fonts.nix
      ./fwupd.nix
      ./geoclue.nix
      ./pipewire.nix
      # ./plymouth.nix
      # ./printing.nix
      ./ratbagd.nix
    ];

    # Packages
    environment.systemPackages = with pkgs; [
      bind
      btop
      dig
      fd
      file
      fzf
      git
      gnugrep
      nmap
      rclone
      sbctl
      tmux
      traceroute
      tree
      unzip
      wget # wget2
      zip

      libva-utils
      usbutils
      vulkan-tools
    ];

    boot.kernel.sysctl = {
      # The Magic SysRq key is a key combo that allows users connected to the
      # system console of a Linux kernel to perform some low-level commands.
      # Disable it, since we don't need it, and is a potential security concern.
      "kernel.sysrq" = 0;

      ## TCP hardening
      # Prevent bogus ICMP errors from filling up logs.
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
      # Reverse path filtering causes the kernel to do source validation of
      # packets received from all interfaces. This can mitigate IP spoofing.
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.conf.all.rp_filter" = 1;
      # Do not accept IP source route packets (we're not a router)
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv6.conf.all.accept_source_route" = 0;
      # Don't send ICMP redirects (again, we're on a router)
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;
      # Refuse ICMP redirects (MITM mitigations)
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.default.accept_redirects" = 0;
      # Protects against SYN flood attacks
      "net.ipv4.tcp_syncookies" = 1;
      # Incomplete protection again TIME-WAIT assassination
      "net.ipv4.tcp_rfc1337" = 1;

      # https://blog.cloudflare.com/optimizing-tcp-for-high-throughput-and-low-latency/#new-settings-under-test-new
      "net.ipv4.tcp_rmem" = lib.mkDefault "8192 262144 536870912";
      "net.ipv4.tcp_wmem" = lib.mkDefault "4096 16384 536870912";
      "net.ipv4.tcp_adv_win_scale" = lib.mkDefault "-2";
      "net.ipv4.tcp_notsent_lowat" = lib.mkDefault (128 * 1024); # 128 KiB
      # Requires Cloudflare TCP collapse patches.
      "net.ipv4.tcp_collapse_max_bytes" = lib.mkDefault (6 * 1024 * 1024); # 6 MiB

      # TCP Fast Open is a TCP extension that reduces network latency by packing
      # data in the sender’s initial TCP SYN.
      #
      # 3 = enable TCP Fast Open for both incoming and outgoing connections.
      "net.ipv4.tcp_fastopen" = lib.mkDefault 3;

      # Bufferbloat mitigations + slight improvement in throughput & latency.
      "net.ipv4.tcp_congestion_control" = lib.mkDefault "bbr";
      "net.core.default_qdisc" = lib.mkDefault "cake";

      # https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes#non-bsd
      "net.core.rmem_max" = lib.mkDefault (builtins.floor (7.5 * 1024 * 1024)); # 7.5 MiB
      "net.core.wmem_max" = lib.mkDefault (builtins.floor (7.5 * 1024 * 1024)); # 7.5 MiB

      # Increase the size of netdev's receive queue, may help prevent losing
      # packets.
      #
      # Defaults to `1000`.
      "net.core.netdev_max_backlog" = lib.mkDefault (16 * 1024); # 16 KiB

      # Disable TCP slow start after idle.
      "net.ipv4.tcp_slow_start_after_idle" = 0;

      # Allow unprivileged users to ping.
      "net.ipv4.ping_group_range" = "0 2147483647";

      # SteamOS/Fedora default, can help with performance.
      "vm.max_map_count" = lib.mkForce 2147483642;

      # TODO: document
      #
      # Recommended for hosts with jumbo frames enabled.
      "net.ipv4.tcp_mtu_probing" = lib.mkDefault 1;
    };

    # Set location provider to manual.
    location.provider = lib.mkDefault "manual";
    location = {
      latitude = 51.05011;
      longitude = -114.08529;
    };

    # Disable NixOS documentation.
    documentation.nixos.enable = false;

    # Override XCURSOR_PATH to only use the full XDG path.
    environment.sessionVariables.XCURSOR_PATH = lib.mkForce ["$HOME/.local/share/icons"];

    # Enable tcpdump
    programs.tcpdump.enable = true;
  };
}
