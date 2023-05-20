{
  config,
  lib,
  ...
}: {
  # Disable systemd-timesyncd in favor of chrony
  services.timesyncd.enable = lib.mkDefault false;
  services.chrony.enable = lib.mkDefault true;

  # Disable systemd-networkd
  systemd.network.enable = lib.mkDefault false;

  # Enable firewall
  networking.firewall = {
    enable = lib.mkDefault true;
    allowPing = lib.mkDefault true;
  };

  # Enable NetworkManager
  networking.networkmanager = {
    enable = lib.mkDefault true;
    plugins = lib.mkForce [];
    dns = lib.mkDefault "systemd-resolved";
  };

  # Disable wireless
  networking.wireless = {
    enable = lib.mkDefault false;
  };

  # Enable systemd-resolved
  services.resolved = {
    enable = lib.mkDefault true;
    dnssec = lib.mkDefault "false";
  };

  # Enable nftables
  networking.nftables = {
    enable = lib.mkDefault true;

    # TODO: remove once https://github.com/NixOS/nixpkgs/pull/231505 is merged
    ruleset = with lib; let
      cfg = config.networking.firewall;

      ifaceSet = concatStringsSep ", " (
        map (x: ''"${x}"'') cfg.trustedInterfaces
      );

      portsToNftSet = ports: portRanges:
        concatStringsSep ", " (
          map (x: toString x) ports
          ++ map (x: "${toString x.from}-${toString x.to}") portRanges
        );
    in ''

      table inet nixos-fw {

        ${optionalString (cfg.checkReversePath != false) ''
        chain rpfilter {
          type filter hook prerouting priority mangle + 10; policy drop;

          meta nfproto ipv4 udp sport . udp dport { 67 . 68, 68 . 67 } accept comment "DHCPv4 client/server"
          fib saddr . mark ${optionalString (cfg.checkReversePath != "loose") ". iif"} oif exists accept

          ${optionalString cfg.logReversePathDrops ''
          log level info prefix "rpfilter drop: "
        ''}

        }
      ''}

        chain input {
          type filter hook input priority filter; policy drop;

          ${optionalString (ifaceSet != "") ''iifname { ${ifaceSet} } accept comment "trusted interfaces"''}

          ct state vmap {
            invalid : drop,
            established : accept,
            related : accept,
          }
          jump input-allow

          ${optionalString cfg.logRefusedConnections ''
        tcp flags syn / fin,syn,rst,ack log level info prefix "refused connection: "
      ''}
          ${optionalString (cfg.logRefusedPackets && !cfg.logRefusedUnicastsOnly) ''
        pkttype broadcast log level info prefix "refused broadcast: "
        pkttype multicast log level info prefix "refused multicast: "
      ''}
          ${optionalString cfg.logRefusedPackets ''
        pkttype host log level info prefix "refused packet: "
      ''}

          ${optionalString cfg.rejectPackets ''
        meta l4proto tcp reject with tcp reset
        reject
      ''}

        }

        chain input-allow {

          ${concatStrings (mapAttrsToList (
          iface: cfg: let
            ifaceExpr = optionalString (iface != "default") "iifname ${iface}";
            tcpSet = portsToNftSet cfg.allowedTCPPorts cfg.allowedTCPPortRanges;
            udpSet = portsToNftSet cfg.allowedUDPPorts cfg.allowedUDPPortRanges;
          in ''
            ${optionalString (tcpSet != "") "${ifaceExpr} tcp dport { ${tcpSet} } accept"}
            ${optionalString (udpSet != "") "${ifaceExpr} udp dport { ${udpSet} } accept"}
          ''
        )
        cfg.allInterfaces)}

          ${optionalString cfg.allowPing ''
        icmp type echo-request ${optionalString (cfg.pingLimit != null) "limit rate ${cfg.pingLimit}"} accept comment "allow ping"
      ''}

          icmpv6 type != { nd-redirect, 139 } accept comment "Accept all ICMPv6 messages except redirects and node information queries (type 139).  See RFC 4890, section 4.4."
          ip6 daddr fe80::/64 udp dport 546 accept comment "DHCPv6 client"

          ${cfg.extraInputRules}

        }

        ${optionalString cfg.filterForward ''
        chain forward {
          type filter hook forward priority filter; policy drop;

          ct state vmap {
            invalid : drop,
            established : accept,
            related : accept,
            new : jump forward-allow,
            untracked : jump forward-allow,
          }

        }

        chain forward-allow {

          icmpv6 type != { router-renumbering, 139 } accept comment "Accept all ICMPv6 messages except renumbering and node information queries (type 139).  See RFC 4890, section 4.3."

          ct status dnat accept comment "allow port forward"

          ${cfg.extraForwardRules}

        }
      ''}

      }

    '';
  };

  # Configure time servers
  networking.timeServers = lib.mkDefault [
    # https://nrc.canada.ca/en/certifications-evaluations-standards/canadas-official-time/network-time-protocol-ntp
    "time.nrc.ca"
    "time.chu.nrc.ca"
  ];

  # Enable mtr
  programs.mtr.enable = lib.mkDefault true;
}
