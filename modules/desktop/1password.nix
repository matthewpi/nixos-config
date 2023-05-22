{
  config,
  lib,
  pkgs,
  ...
}: {
  programs._1password.enable = lib.mkDefault true;
  programs._1password-gui = {
    enable = lib.mkDefault true;
    package = lib.mkDefault pkgs._1password-gui-beta;
  };

  # TODO: add an option to enable/disable this behaviour?
  environment.systemPackages = lib.mkIf config.programs._1password-gui.enable [
    (pkgs.makeAutostartItem {
      name = "1password";
      package = config.programs._1password-gui.package;
    })
  ];
}
