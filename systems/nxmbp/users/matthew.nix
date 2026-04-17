{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../../users/matthew/catppuccin.nix

    ../../../users/matthew/cli/atuin.nix
    ../../../users/matthew/cli/bat.nix
    ../../../users/matthew/cli/bottom.nix
    ../../../users/matthew/cli/direnv.nix
    ../../../users/matthew/cli/eza.nix
    ../../../users/matthew/cli/fzf.nix
    ../../../users/matthew/cli/gh.nix
    ../../../users/matthew/cli/git.nix
    ../../../users/matthew/cli/kubernetes.nix
    ../../../users/matthew/cli/man.nix
    ../../../users/matthew/cli/neovim.nix
    ../../../users/matthew/cli/nix-index.nix
    ../../../users/matthew/cli/nodejs.nix
    ../../../users/matthew/cli/ripgrep.nix
    ../../../users/matthew/cli/ssh.nix
    ../../../users/matthew/cli/starship.nix
    ../../../users/matthew/cli/tmux.nix
    ../../../users/matthew/cli/zsh.nix

    ../../../users/matthew/desktop/applications/terminal.nix
    ../../../users/matthew/desktop/applications/zed-editor.nix
  ];

  home = {
    stateVersion = "26.05";

    homeDirectory = "/Users/${config.home.username}";
    username = "matthew";

    preferXdgDirectories = true;
  };

  home.sessionVariables = {
    XDG_CACHE_HOME = "${config.home.homeDirectory}/.cache";
    XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
    XDG_DATA_HOME = "${config.home.homeDirectory}/.local/share";
    XDG_STATE_HOME = "${config.home.homeDirectory}/.local/state";
  };

  # Enable home-manager.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    nh

    # Install Go globally since sometimes Zed Editor doesn't pick it up.
    go_1_26
    gopls

    docker-compose
    docker-credential-helpers
  ];

  # Pre-configure auth to use the `osxkeychain` credential helper instead
  # of storing credentials on disk in plain-text.
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
