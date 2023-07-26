{lib, ...}: {
  # Enable chrony in favor of systemd-timesyncd.
  services.chrony.enable = lib.mkDefault true;
  services.timesyncd.enable = lib.mkDefault false;

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
