{inputs, ...}: {
  perSystem = {
    lib,
    pkgs,
    system,
    ...
  }: let
    _packages = {
      _1password-gui = pkgs.callPackage ./1password-gui {};
      _1password-gui-beta = pkgs.callPackage ./1password-gui {channel = "beta";};

      catppuccin = pkgs.callPackage ./catppuccin {};
      catppuccin-hyprcursors = pkgs.callPackage ./catppuccin/hyprcursors.nix {};
      catppuccin-wallpapers = pkgs.callPackage ./catppuccin/wallpapers {};

      cider2 = pkgs.callPackage ./cider2 {};

      fast-syntax-highlighting = pkgs.callPackage ./zsh/fast-syntax-highlighting.nix {};
      zsh-titles = pkgs.callPackage ./zsh/zsh-titles.nix {};

      inter = pkgs.callPackage ./inter.nix {};
      monaspace = pkgs.callPackage ./monaspace.nix {};

      openlens = pkgs.callPackage ./openlens {};
    };
  in {
    packages = lib.attrsets.filterAttrs (_: v: builtins.elem system v.meta.platforms) _packages;

    overlayAttrs = let
      _1passwordPreFixup = ''
        makeShellWrapper $out/share/1password/1password $out/bin/1password \
          "''${gappsWrapperArgs[@]}" \
          --suffix PATH : ${lib.makeBinPath [pkgs.xdg-utils]} \
          --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [pkgs.udev]} \
          --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --use-tray-icon}}"
      '';
    in {
      inherit
        (_packages)
        catppuccin
        catppuccin-hyprcursors
        catppuccin-wallpapers
        cider2
        fast-syntax-highlighting
        inter
        monaspace
        openlens
        zsh-titles
        ;

      _1password-gui = _packages._1password-gui.overrideAttrs (_: {preFixup = _1passwordPreFixup;});
      _1password-gui-beta = _packages._1password-gui-beta.overrideAttrs (_: {preFixup = _1passwordPreFixup;});

      signal-desktop = pkgs.signal-desktop.overrideAttrs (old: {
        preFixup =
          old.preFixup
          + ''
            gappsWrapperArgs+=(
              --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --use-tray-icon}}"
            )
          '';
      });

      # Flake overlays
      hyprcursor = inputs.hyprcursor.packages.${system}.hyprcursor;
      hypridle = inputs.hypridle.packages.${system}.hypridle;
      hyprland = inputs.hyprland.packages.${system}.hyprland;
      hyprlang = inputs.hyprlang.packages.${system}.hyprlang;
      hyprlock = inputs.hyprlock.packages.${system}.hyprlock;
      hyprpaper = inputs.hyprpaper.packages.${system}.hyprpaper;
      hyprpicker = inputs.hyprpicker.packages.${system}.hyprpicker;
      xdg-desktop-portal-hyprland = inputs.xdph.packages.${system}.xdg-desktop-portal-hyprland;
    };
  };
}
