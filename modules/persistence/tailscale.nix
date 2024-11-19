{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.services.tailscale.enable {
    environment.persistence."/persist".directories = [
      {
        directory = "/var/cache/tailscale";
        mode = "0750";
      }
      {
        directory = "/var/lib/tailscale";
        mode = "0700";
      }
    ];
  };
}
