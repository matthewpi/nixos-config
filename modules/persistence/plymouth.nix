{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.boot.plymouth.enable {
    environment.persistence."/persist".directories = ["/var/lib/plymouth"];
  };
}
