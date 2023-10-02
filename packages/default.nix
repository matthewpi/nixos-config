{
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    packages = {
      _1password-gui = pkgs.callPackage ./1password-gui/default.nix {};
      _1password-gui-beta = pkgs.callPackage ./1password-gui/default.nix {channel = "beta";};
      catppuccin-k9s = pkgs.callPackage ./catppuccin/k9s.nix {};
      catppuccin-plymouth = pkgs.callPackage ./catppuccin/plymouth.nix {};
      catppuccin-wallpapers = pkgs.callPackage ./catppuccin/wallpapers/default.nix {};
      fast-syntax-highlighting = pkgs.callPackage ./fast-syntax-highlighting.nix {};
      podman = pkgs.callPackage ./podman/default.nix {};
    };

    overlayAttrs = {
      inherit
        (config.packages)
        _1password-gui
        _1password-gui-beta
        catppuccin-k9s
        catppuccin-plymouth
        catppuccin-wallpapers
        fast-syntax-highlighting
        podman
        ;
    };
  };
}
