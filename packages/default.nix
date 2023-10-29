{
  perSystem = {
    config,
    lib,
    pkgs,
    ...
  }: {
    packages = {
      catppuccin-k9s = pkgs.callPackage ./catppuccin/k9s.nix {};
      catppuccin-plymouth = pkgs.callPackage ./catppuccin/plymouth.nix {};
      catppuccin-wallpapers = pkgs.callPackage ./catppuccin/wallpapers/default.nix {};

      cider2 = pkgs.callPackage ./cider2/default.nix {};

      fast-syntax-highlighting = pkgs.callPackage ./fast-syntax-highlighting.nix {};
    };

    overlayAttrs = let
      _1passwordPreFixup = ''
        makeShellWrapper $out/share/1password/1password $out/bin/1password \
          "''${gappsWrapperArgs[@]}" \
          --suffix PATH : ${lib.makeBinPath [pkgs.xdg-utils]} \
          --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [pkgs.udev]} \
          --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --use-tray-icon}}"
      '';
    in {
      inherit
        (config.packages)
        catppuccin-k9s
        catppuccin-plymouth
        catppuccin-wallpapers
        cider2
        fast-syntax-highlighting
        ;

      _1password-gui = pkgs._1password-gui.overrideAttrs (_: {preFixup = _1passwordPreFixup;});
      _1password-gui-beta = pkgs._1password-gui-beta.overrideAttrs (_: {preFixup = _1passwordPreFixup;});

      signal-desktop = pkgs.signal-desktop.overrideAttrs (old: {
        preFixup =
          old.preFixup
          + ''
            gappsWrapperArgs+=(
              --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --use-tray-icon}}"
            )
          '';
      });
    };
  };
}
