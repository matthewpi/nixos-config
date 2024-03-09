{
  config,
  outputs,
  ...
}: {
  # Enable our overlays to replace built-in packages.
  nixpkgs.overlays = builtins.attrValues outputs.overlays;

  # Enable home-manager.
  programs.home-manager.enable = true;

  # Allow unfree nixpkgs.
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  home = {
    stateVersion = "23.05";
    username = "matthew";
  };

  home.sessionVariables = {
    XDG_CACHE_HOME = config.xdg.cacheHome;
    XDG_CONFIG_HOME = config.xdg.configHome;
    XDG_DATA_HOME = config.xdg.dataHome;
    XDG_STATE_HOME = config.xdg.stateHome;

    # Change CARGO_HOME from the default ~/.cargo location to follow the XDG spec.
    CARGO_HOME = "${config.home.sessionVariables.XDG_DATA_HOME}/cargo";

    # Change GNUPGHOME from the default ~/.gnupg location to follow the XDG spec.
    GNUPGHOME = "${config.home.sessionVariables.XDG_DATA_HOME}/gnupg";

    # Change GOPATH from the default ~/go location to follow the XDG spec.
    GOPATH = "${config.home.sessionVariables.XDG_DATA_HOME}/go";

    #_JAVA_OPTIONS = "-Djava.util.prefs.userRoot=${config.home.sessionVariables.XDG_CONFIG_HOME}/java";
  };

  # Add all sessionVariables to systemd.
  systemd.user.sessionVariables = config.home.sessionVariables;
}
