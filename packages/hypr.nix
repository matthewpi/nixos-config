{inputs, ...}: {
  perSystem = {
    lib,
    system,
    ...
  }: let
    fixPathForLazyTrees = input: attr:
      input.packages.${system}.${attr}.overrideAttrs {
        src = builtins.path {
          name = "source";
          path = input;
        };
      };

    _packages = rec {
      aquamarine = (fixPathForLazyTrees inputs.aquamarine "aquamarine").override {
        inherit hyprutils hyprwayland-scanner;
      };

      hyprcursor = (fixPathForLazyTrees inputs.hyprcursor "hyprcursor").override {
        inherit hyprlang;
      };

      hypridle = (fixPathForLazyTrees inputs.hypridle "hypridle").override {
        inherit hyprland-protocols hyprlang hyprutils hyprwayland-scanner;
      };

      hyprland = (fixPathForLazyTrees inputs.hyprland "hyprland").override {
        inherit aquamarine hyprcursor hyprgraphics hyprland-protocols hyprland-qtutils hyprlang hyprutils hyprwayland-scanner;
      };

      hyprland-protocols = fixPathForLazyTrees inputs.hyprland-protocols "hyprland-protocols";

      hyprland-qt-support = (fixPathForLazyTrees inputs.hyprland-qt-support "hyprland-qt-support").override {
        inherit hyprlang;
      };

      hyprland-qtutils = (fixPathForLazyTrees inputs.hyprland-qtutils "hyprland-qtutils").override {
        inherit hyprland-qt-support hyprutils;
      };

      hyprlang = (fixPathForLazyTrees inputs.hyprlang "hyprlang").override {
        inherit hyprutils;
      };

      hyprlock = (fixPathForLazyTrees inputs.hyprlock "hyprlock").override {
        inherit hyprlang hyprgraphics hyprwayland-scanner hyprutils;
      };

      hyprgraphics = (fixPathForLazyTrees inputs.hyprgraphics "hyprgraphics").override {
        inherit hyprutils;
      };

      hyprpaper = (fixPathForLazyTrees inputs.hyprpaper "hyprpaper").override {
        inherit hyprlang hyprgraphics hyprutils hyprwayland-scanner;
      };

      hyprpolkitagent = (fixPathForLazyTrees inputs.hyprpolkitagent "hyprpolkitagent").override {
        inherit hyprland-qt-support hyprutils;
      };

      hyprutils = fixPathForLazyTrees inputs.hyprutils "hyprutils";

      hyprwayland-scanner = fixPathForLazyTrees inputs.hyprwayland-scanner "hyprwayland-scanner";

      xdg-desktop-portal-hyprland = (fixPathForLazyTrees inputs.xdph "xdg-desktop-portal-hyprland").override {
        inherit hyprland hyprland-protocols hyprlang hyprutils hyprwayland-scanner;
      };
    };
  in {
    packages = lib.attrsets.filterAttrs (_: v: builtins.elem system v.meta.platforms) _packages;
    overlayAttrs = _packages;
  };
}
