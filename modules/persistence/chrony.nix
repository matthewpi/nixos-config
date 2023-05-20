{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.services.chrony.enable {
    environment.persistence."/persist".directories = ["/var/lib/chrony"];
  };
}
