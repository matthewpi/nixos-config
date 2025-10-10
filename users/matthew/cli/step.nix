{
  config,
  pkgs,
  ...
}: {
  home.sessionVariables.STEPPATH = "${config.home.sessionVariables.XDG_DATA_HOME}/step";

  home.packages = [
    pkgs.step-cli
    # pkgs.step-kms-plugin
  ];
}
