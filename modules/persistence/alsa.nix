{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.sound.enable || config.services.pipewire.alsa.enable) {
    environment.persistence."/persist".directories = ["/var/lib/alsa"];
  };
}
