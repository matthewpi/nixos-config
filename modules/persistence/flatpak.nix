{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.services.flatpak.enable {
    environment.persistence."/persist".directories = ["/var/lib/flatpak"];
  };
}
