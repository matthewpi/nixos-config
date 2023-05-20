{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.services.openssh.enable {
    # Secure OpenSSH
    services.openssh.settings = {
      PasswordAuthentication = lib.mkDefault false;
      PermitRootLogin = lib.mkDefault "no";
    };

    # Allow incoming SSH connections on all interfaces if Tailscale is disabled
    networking.firewall = lib.mkMerge [
      (lib.mkIf (! config.services.tailscale.enable) {
        allowedTCPPorts = config.services.openssh.ports;
      })
    ];
  };
}
