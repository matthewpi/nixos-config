{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.networking.networkmanager.enable {
    environment.persistence."/persist" = {
      directories = [
        "/etc/NetworkManager/system-connections"
        "/var/lib/NetworkManager"
      ];
    };
  };
}
