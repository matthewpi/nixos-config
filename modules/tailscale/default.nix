{
  flake.nixosModules.tailscale = {lib, ...}: {
    imports = [
      # ./hardening.nix
      ./nftables.nix
    ];

    services.tailscale = {
      openFirewall = lib.mkDefault true;
      extraDaemonFlags = ["--no-logs-no-support" "--encrypt-state"];
      useRoutingFeatures = lib.mkDefault "client";
      disableTaildrop = lib.mkDefault true;
    };
  };
}
