{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.sound.enable {
    environment.persistence."/persist".directories = ["/var/lib/alsa"];
  };
}
