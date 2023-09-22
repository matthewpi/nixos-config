{
  perSystem = {
    config,
    lib,
    pkgs,
    ...
  }: {
    packages = let
      jetbrains =
        lib.recurseIntoAttrs (pkgs.callPackages ./jetbrains {
          vmopts = config.jetbrains.vmopts or null;
          jdk = jetbrains.jdk;
        })
        // {
          jdk = pkgs.jetbrains.jdk;
          jcef = pkgs.jetbrains.jcef;
        };
    in {
      _1password-gui = pkgs.callPackage ./1password-gui/default.nix {};
      _1password-gui-beta = pkgs.callPackage ./1password-gui/default.nix {channel = "beta";};

      catppuccin-k9s = pkgs.callPackage ./catppuccin/k9s.nix {};
      catppuccin-plymouth = pkgs.callPackage ./catppuccin/plymouth.nix {};

      fast-syntax-highlighting = pkgs.callPackage ./fast-syntax-highlighting.nix {};

      jetbrains-datagrip = jetbrains.datagrip;
      jetbrains-goland = jetbrains.goland;
      jetbrains-idea-ultimate = jetbrains.idea-ultimate;
      jetbrains-phpstorm = jetbrains.phpstorm;
      jetbrains-webstorm = jetbrains.webstorm;
    };

    overlayAttrs = {
      inherit
        (config.packages)
        _1password-gui
        _1password-gui-beta
        catppuccin-k9s
        catppuccin-plymouth
        fast-syntax-highlighting
        jetbrains-datagrip
        jetbrains-goland
        jetbrains-idea-ultimate
        jetbrains-phpstorm
        jetbrains-webstorm
        ;
    };
  };
}
