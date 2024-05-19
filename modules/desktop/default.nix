{
  flake.nixosModules.desktop = {
    lib,
    pkgs,
    ...
  }: {
    imports = [
      ./1password.nix
      ./bluetooth.nix
      ./corectrl.nix
      ./dconf.nix
      ./fonts.nix
      ./gamemode.nix
      ./pipewire.nix
      ./plymouth.nix
      #./printing.nix
      ./ratbagd.nix
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

      ## TCP optimization
      # TCP Fast Open is a TCP extension that reduces network latency by packing
      # data in the sender’s initial TCP SYN. Setting 3 = enable TCP Fast Open for
      # both incoming and outgoing connections:
      "net.ipv4.tcp_fastopen" = 3;
      # Bufferbloat mitigations + slight improvement in throughput & latency
      "net.ipv4.tcp_congestion_control" = "bbr"; # TODO: only enable if we are running a kernel with tcp_bbr support
      "net.core.default_qdisc" = "cake";

      # https://github.com/quic-go/quic-go/wiki/UDP-Receive-Buffer-Size#non-bsd
      "net.core.rmem_max" = 2500000;

      # Allow unprivileged users to ping.
      "net.ipv4.ping_group_range" = "0 2147483647";
    };

    # Extra packages
    environment.systemPackages = with pkgs; [
      libva-utils
      usbutils
      vulkan-tools
    ];

    # Set location provider to geoclue2.
    location.provider = lib.mkDefault "geoclue2";
    systemd.user.services.geoclue-agent.serviceConfig.Slice = "background.slice";

    # Disable NixOS documentation.
    documentation.nixos.enable = false;

    # Override XCURSOR_PATH to only use the full XDG path.
    environment.sessionVariables.XCURSOR_PATH = lib.mkForce ["$HOME/.local/share/icons"];
  };
}
