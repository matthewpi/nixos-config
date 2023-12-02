{
  lib,
  pkgs,
  ...
}: {
  boot.plymouth = {
    enable = lib.mkDefault true;
    font = lib.mkDefault "${pkgs.inter}/share/fonts/opentype/Inter/Inter-Regular.otf";
  };
}
