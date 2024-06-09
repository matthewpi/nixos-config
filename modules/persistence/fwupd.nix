{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.services.fwupd.enable {
    environment.persistence."/persist".directories = [
      "/var/cache/fwupd"
      "/var/lib/fwupd"
    ];
  };
}
