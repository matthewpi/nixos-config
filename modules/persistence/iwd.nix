{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.networking.wireless.iwd.enable {
    environment.persistence."/persist".directories = ["/var/lib/iwd"];
  };
}
