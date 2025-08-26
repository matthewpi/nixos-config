{lib, ...}: {
  # Enable systemd-timesyncd in favor of chrony by default.
  services.timesyncd.enable = lib.mkDefault true;
  services.chrony.enable = lib.mkDefault false;

  # Configure time servers.
  networking.timeServers = lib.mkDefault ["time.cloudflare.com"];

  # Enable systemd-networkd by default.
  systemd.network.enable = true;
  networking.useNetworkd = true;

  # Enable firewall
  networking.firewall = {
    enable = lib.mkDefault true;
    allowPing = lib.mkDefault true;
  };

  # Disable NetworkManager by default when systemd-networkd is disabled.
  networking.networkmanager = {
    enable = lib.mkForce false;
    dns = "systemd-resolved";
    plugins = lib.mkForce [];
  };

  # Disable wireless by default.
  networking.wireless.enable = lib.mkDefault false;

  # Enable systemd-resolved by default.
  services.resolved = {
    enable = true;
    llmnr = lib.mkDefault "false";
    dnssec = lib.mkDefault "false";
  };

  # Enable nftables by default.
  networking.nftables.enable = lib.mkDefault true;

  # Enable mtr
  programs.mtr.enable = lib.mkDefault true;
}
