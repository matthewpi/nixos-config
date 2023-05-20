{
  flake.nixosModules.podman = {lib, ...}: {
    # Enable Podman
    virtualisation.podman = {
      enable = lib.mkDefault true;
      dockerCompat = lib.mkDefault true;
    };

    # Enable CRIU
    programs.criu.enable = lib.mkDefault true;

    # Enable kernel modules required for networking with Podman
    boot.kernelModules = [
      "bridge"
      "libcrc32c"
      "llc"

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

      "veth"
      "stp"

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

    # Allow access to privileged ports above or equal to 80
    boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = lib.mkDefault 80;

    # Allow some insecure registries to be used
    virtualisation.containers.registries.insecure = lib.mkDefault ["127.0.0.1:8790" "localhost:8790"];
  };
}
