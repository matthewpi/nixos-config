{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.networking.networkmanager.enable {
    environment.persistence."/persist" = {
      directories = ["/etc/NetworkManager/system-connections"];

      files = [
        "/var/lib/NetworkManager/NetworkManager.state"
        "/var/lib/NetworkManager/secret_key"
        "/var/lib/NetworkManager/seen-bssids"
        "/var/lib/NetworkManager/timestamps"
      ];
    };
  };
}
