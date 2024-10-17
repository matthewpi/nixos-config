{
  config,
  lib,
  ...
}: {
  # Enable systemd-timesyncd in favor of chrony by default.
  services.timesyncd.enable = lib.mkDefault true;
  services.chrony.enable = lib.mkDefault false;

  # Configure time servers.
  networking.timeServers = lib.mkDefault ["time.cloudflare.com"];

  # Enable systemd-networkd by default.
  systemd.network.enable = lib.mkDefault true;
  networking.useNetworkd = lib.mkDefault true;

  # Enable firewall
  networking.firewall = {
    enable = lib.mkDefault true;
    allowPing = lib.mkDefault true;
  };

  # Disable NetworkManager by default when systemd-networkd is disabled.
  networking.networkmanager = {
    enable =
      if config.systemd.network.enable
      then lib.mkForce false
      else lib.mkDefault true;
    dns =
      if config.services.resolved.enable
      then lib.mkDefault "systemd-resolved"
      else lib.mkDefault "default";
    plugins = lib.mkForce [];
  };

  # Disable wireless by default.
  networking.wireless.enable = lib.mkDefault false;

  # Enable systemd-resolved by default.
  services.resolved = {
    enable = lib.mkDefault true;
    llmnr = lib.mkDefault "false";
    dnssec = lib.mkDefault "false";
  };

  # Enable nftables by default.
  networking.nftables.enable = lib.mkDefault true;

  # Enable mtr
  programs.mtr.enable = lib.mkDefault true;
}
