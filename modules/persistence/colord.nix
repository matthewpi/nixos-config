{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.services.colord.enable {
    environment.persistence."/persist".directories = ["/var/lib/colord"];
  };
}
