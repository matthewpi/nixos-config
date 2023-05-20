{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.hardware.bluetooth.enable {
    environment.persistence."/persist".directories = ["/var/lib/bluetooth"];
  };
}
