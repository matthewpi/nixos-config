{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.polkit;
in {
  imports = [
    ./gnome.nix
    ./hypr.nix
  ];

  options.services.polkit = {
    enable = lib.mkEnableOption "polkit";

    agent = lib.mkOption {
      type = lib.types.enum ["gnome" "hypr"];
      default = "gnome";
      example = "hypr";
      description = ''
        The polkit agent to use.
      '';
    };

    package = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = cfg.packages."${cfg.agent}";
      defaultText = lib.literalExpression ''config.services.polkit.packages."${config.services.polkit.agent}"'';
      description = ''
        The package used for the polkit agent.

        This option is readOnly and cannot be modified, if you wish to override the
        package that is used, configure {option}`services.polkit.packages` instead.
      '';
    };

    packages = {
      gnome = lib.mkOption {
        type = lib.types.package;
        default = pkgs.polkit_gnome;
      };

      hypr = lib.mkOption {
        type = lib.types.package;
        default = pkgs.polkit_gnome;
        # default = pkgs.hyprpolkitagent;
      };
    };
  };
}
