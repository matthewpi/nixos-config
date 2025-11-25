{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.services.ollama.enable {
    environment.persistence."/persist".directories = [
      "/var/lib/private/ollama"
    ];
  };
}
