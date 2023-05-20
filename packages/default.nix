{
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    packages = {
      catppuccin-plymouth = pkgs.callPackage ./catppuccin/plymouth.nix {};

      fast-syntax-highlighting = pkgs.callPackage ./fast-syntax-highlighting.nix {};

      xwaylandvideobridge = pkgs.libsForQt5.callPackage ./xwaylandvideobridge.nix {};
    };

    overlayAttrs = {
      inherit (config.packages) catppuccin-plymouth fast-syntax-highlighting xwaylandvideobridge;
    };
  };
}
