{
  config,
  lib,
  ...
}: let
  cfg = config.services.podman;
in {
  services.podman = {
    enable = true;

    # Allow some insecure registries to be used.
    # registries.insecure = lib.mkDefault ["127.0.0.1:8790" "localhost:8790"];
  };

  # TODO: PR into home-manager
  xdg.configFile = lib.mkIf cfg.enable {
    "systemd/user/podman.socket".source = "${cfg.package}/share/systemd/user/podman.socket";
    "systemd/user/podman.service".source = "${cfg.package}/share/systemd/user/podman.service";
  };
}
