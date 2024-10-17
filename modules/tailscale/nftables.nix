{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.services.tailscale.enable && config.networking.nftables.enable) {
    # Configure Tailscale to explicitly use nftables instead of attempting to detect it.
    # ref; https://tailscale.com/kb/1294/firewall-mode#how-to-set-the-firewall-mode
    systemd.services.tailscaled.serviceConfig.Environment = ["TS_DEBUG_FIREWALL_MODE=nftables"];

    # If nftables and tailscale are enabled, make sure to load the required kernel modules.
    boot.kernelModules = [
      "nf_conntrack"
      "nf_conntrack_broadcast"
      "nft_chain_nat"
      "nft_ct"
      "nft_fib"
      "nft_fib_inet"
      "nft_fib_ipv4"
      "nft_fib_ipv6"
      "nf_nat"
      "nft_reject"
      "nft_reject_inet"
      "nf_reject_ipv4"
      "nf_reject_ipv6"

      "xt_addrtype"
      "xt_CHECKSUM"
      "xt_comment"
      "xt_conntrack"
      "xt_mark"
      "xt_MASQUERADE"
      "xt_multiport"
      "xt_nat"
      "xt_tcpudp"
    ];
  };
}
