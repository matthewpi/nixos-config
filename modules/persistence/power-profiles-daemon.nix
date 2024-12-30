{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.services.power-profiles-daemon.enable {
    environment.persistence."/persist".directories = ["/var/lib/power-profiles-daemon"];
  };
}
