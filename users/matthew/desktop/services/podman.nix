{
  config,
  pkgs,
  ...
}: let
  cfg = config.services.podman;
in {
  services.podman.enable = true;

  xdg.configFile = {
    # TODO: PR into home-manager
    "systemd/user/podman.socket".source = "${cfg.package}/share/systemd/user/podman.socket";
    "systemd/user/podman.service".source = "${cfg.package}/share/systemd/user/podman.service";
    "systemd/user/sockets.target.wants/podman.socket".source = "${cfg.package}/share/systemd/user/podman.socket";

    # Pre-configure auth to use the `secretservice` credential helper instead
    # of storing credentials on disk in a plain-text.
    "containers/auth.json".text = builtins.toJSON {
      credHelpers = {
        "docker.io" = "secretservice";
        "ghcr.io" = "secretservice";
        "quay.io" = "secretservice";
        "zot.blahaj.systems" = "secretservice";
      };
    };
  };

  home.packages = [
    pkgs.docker-credential-helpers
    pkgs.docker-compose
    pkgs.kind
  ];

  home.sessionVariables = {
    PODMAN_COMPOSE_WARNING_LOGS = "false";
    PODMAN_COMPOSE_PROVIDER = "${pkgs.docker-compose}/libexec/docker/cli-plugins/docker-compose";

    # Set DOCKER_HOST to point to the rootless Podman socket.
    DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";

    REGISTRY_AUTH_FILE = "${config.home.sessionVariables.XDG_CONFIG_HOME}/containers/auth.json";
  };
}
