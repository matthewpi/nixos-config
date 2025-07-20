{
  flake.nixosModules._1password = {
    lib,
    pkgs,
    ...
  }: {
    disabledModules = ["programs/_1password-gui.nix"];
    imports = [./module.nix];

    programs._1password.enable = lib.mkDefault true;

    programs._1password-gui = {
      enable = lib.mkDefault true;
      package = lib.mkDefault pkgs._1password-gui-beta;
    };
  };
}
