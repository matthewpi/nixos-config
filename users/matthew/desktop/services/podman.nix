{
  config,
  lib,
  pkgs,
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
    "systemd/user/sockets.target.wants/podman.socket".source = "${cfg.package}/share/systemd/user/podman.socket";
  };

  home.packages = [
    pkgs.docker-compose
    pkgs.kind
  ];

  home.sessionVariables = {
    PODMAN_COMPOSE_WARNING_LOGS = "false";
    PODMAN_COMPOSE_PROVIDER = "${pkgs.docker-compose}/libexec/docker/cli-plugins/docker-compose";

    # Set DOCKER_HOST to point to the rootless Podman socket.
    DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";
  };
}
