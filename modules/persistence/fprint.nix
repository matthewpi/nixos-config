{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.services.fprintd.enable {
    environment.persistence."/persist".directories = ["/var/lib/fprint"];
  };
}
