{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = [
    pkgs.docker-client
    pkgs.docker-compose
    pkgs.docker-credential-helpers
  ];

  launchd.agents.socktainer = {
    enable = true;
    config = {
      ProgramArguments = [(lib.getExe pkgs.socktainer)];
      KeepAlive = true;
      ProcessType = "Background";
      RunAtLoad = true;
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/socktainer/socktainer.err.log";
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/socktainer/socktainer.log";
    };
  };

  # Configure Docker (and other tools) to use socktainer.
  home.sessionVariables.DOCKER_HOST = "unix://${config.home.homeDirectory}/.socktainer/container.sock";

  # Preconfigure container tools to use the `osxkeychain` credential helper
  # instead of storing credentials on disk in plain-text.
  xdg.configFile."containers/auth.json".text = builtins.toJSON {
    credHelpers = {
      "docker.io" = "osxkeychain";
      "ghcr.io" = "osxkeychain";
      "quay.io" = "osxkeychain";

      "zot.blahaj.systems" = "osxkeychain";
    };
  };
  home.sessionVariables.REGISTRY_AUTH_FILE = "${config.xdg.configHome}/containers/auth.json";
}
