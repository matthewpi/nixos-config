{
  perSystem = {
    lib,
    pkgs,
    system,
    ...
  }: let
    _packages =
      {
        catppuccin = pkgs.callPackage ./catppuccin {};
        catppuccin-wallpapers = pkgs.callPackage ./catppuccin/wallpapers {};

        cider2 = pkgs.callPackage ./cider2 {};

        fast-syntax-highlighting = pkgs.callPackage ./zsh/fast-syntax-highlighting.nix {};
        zsh-titles = pkgs.callPackage ./zsh/zsh-titles.nix {};

        inter = pkgs.callPackage ./inter.nix {};
        monaspace = pkgs.callPackage ./monaspace.nix {};

        zed-editor = pkgs.callPackage ./zed-editor {};
      }
      // lib.optionalAttrs (pkgs.stdenv.system == "x86_64-linux") {
        forge-sparks = pkgs.callPackage ./forge-sparks {};
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
        catppuccin-wallpapers
        cider2
        fast-syntax-highlighting
        forge-sparks
        inter
        monaspace
        zed-editor
        zsh-titles
        ;

      _1password-gui = pkgs._1password-gui.overrideAttrs (_: {preFixup = _1passwordPreFixup;});
      _1password-gui-beta = pkgs._1password-gui-beta.overrideAttrs (_: {preFixup = _1passwordPreFixup;});

      signal-desktop = pkgs.signal-desktop.overrideAttrs (old: {
        preFixup =
          old.preFixup
          + ''
            gappsWrapperArgs+=(
              --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --use-tray-icon}}"
            )
          '';
      });

      webcord = pkgs.callPackage ./webcord/default.nix {};
    };
  };
}
