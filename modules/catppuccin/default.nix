{
  flake.nixosModules.catppuccin = {
    config,
    lib,
    pkgs,
    ...
  }: let
    # Catppuccin flavour
    # https://github.com/catppuccin/catppuccin#-palette
    flavour = "mocha";
  in {
    # Theme plymouth if it is enabled
    config.boot.plymouth = lib.mkIf config.boot.plymouth.enable {
      themePackages = [pkgs.catppuccin-plymouth];
      theme = "catppuccin-${flavour}";
    };
  };
}
