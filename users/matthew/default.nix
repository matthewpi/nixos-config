{
  config,
  inputs,
  outputs,
  ...
}: {
  # Enable our overlays to replace built-in packages.
  nixpkgs.overlays = builtins.attrValues outputs.overlays;

  imports = [
    inputs.nur.hmModules.nur
  ];

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
    # Change GOPATH from the default ~/go location to reduce clutter.
    GOPATH = "${config.home.homeDirectory}/.local/share/go";
  };
}
