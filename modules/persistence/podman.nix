{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.virtualisation.podman.enable {
    environment.persistence."/persist".directories = [
      "/var/lib/cni"
      "/var/lib/containers"
    ];
  };
}
