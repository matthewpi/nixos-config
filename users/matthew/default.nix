{config, ...}: {
  imports = [
    ./catppuccin.nix
  ];

  # Enable home-manager.
  programs.home-manager.enable = true;

  home = {
    stateVersion = "23.05";
    username = "matthew";
    preferXdgDirectories = true;
  };

  home.sessionVariables = {
    XDG_CACHE_HOME = config.xdg.cacheHome;
    XDG_CONFIG_HOME = config.xdg.configHome;
    XDG_DATA_HOME = config.xdg.dataHome;
    XDG_STATE_HOME = config.xdg.stateHome;

    # Make AWS CLI follow the XDG spec.
    AWS_CONFIG_FILE = "${config.home.sessionVariables.XDG_CONFIG_HOME}/aws/config";
    AWS_SHARED_CREDENTIALS_FILE = "${config.home.sessionVariables.XDG_CONFIG_HOME}/aws/credentials";

    # Change CARGO_HOME from the default ~/.cargo location to follow the XDG spec.
    CARGO_HOME = "${config.home.sessionVariables.XDG_DATA_HOME}/cargo";

    # Change GNUPGHOME from the default ~/.gnupg location to follow the XDG spec.
    GNUPGHOME = "${config.home.sessionVariables.XDG_DATA_HOME}/gnupg";

    # Change GOPATH from the default ~/go location to follow the XDG spec.
    GOPATH = "${config.home.sessionVariables.XDG_DATA_HOME}/go";

    # Force Go to always use the locally available toolchain, even if a project
    # requests a different version.
    GOTOOLCHAIN = "local";

    #_JAVA_OPTIONS = "-Djava.util.prefs.userRoot=${config.home.sessionVariables.XDG_CONFIG_HOME}/java";
  };

  # Add all sessionVariables to systemd.
  systemd.user.sessionVariables = config.home.sessionVariables;
}
