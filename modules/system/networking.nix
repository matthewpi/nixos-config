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
    enable = lib.mkDefault true;
    settings.Resolve = {
      DNSSEC = lib.mkDefault false;
      LLMNR = lib.mkDefault false;
    };
  };

  # Enable nftables by default.
  networking.nftables.enable = lib.mkDefault true;

  # Enable mtr
  programs.mtr.enable = lib.mkDefault true;

  # Stop delaying boot until the network is online.
  #
  # Any service incapable of handling offline networking or networking
  # connecting well after boot should be fixed.
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;
}
