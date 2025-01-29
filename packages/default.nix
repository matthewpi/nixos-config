{inputs, ...}: {
  flake.overlays.util-linux-fix = _: super: {
    utillinux = super.util-linux;
  };

  perSystem = {
    lib,
    pkgs,
    system,
    ...
  }: let
    _packages = rec {
      _1password-gui = pkgs.callPackage ./1password-gui {};
      _1password-gui-beta = pkgs.callPackage ./1password-gui {channel = "beta";};
      catppuccin = pkgs.callPackage ./catppuccin {};
      catppuccin-wallpapers = pkgs.callPackage ./catppuccin/wallpapers {};
      cider2 = pkgs.callPackage ./cider2 {};
      hoppscotch = pkgs.callPackage ./hoppscotch {};
      hoppscotch-desktop-unwrapped = pkgs.callPackage ./hoppscotch-desktop {inherit hoppscotch;};
      hoppscotch-desktop = pkgs.callPackage ./hoppscotch-desktop/wrapper.nix {inherit hoppscotch-desktop-unwrapped;};
      package-version-server = pkgs.callPackage ./package-version-server {};
      simple-completion-language-server = pkgs.callPackage ./simple-completion-language-server {};
      fast-syntax-highlighting = pkgs.callPackage ./zsh/fast-syntax-highlighting.nix {};
      inter = pkgs.callPackage ./inter.nix {};
      monaspace = pkgs.callPackage ./monaspace.nix {};
      vesktop = pkgs.callPackage ./vesktop/package.nix {vesktop = pkgs.vesktop;};
      vulkan-hdr-layer = pkgs.callPackage ./vulkan-hdr-layer {};
      zsh-titles = pkgs.callPackage ./zsh/zsh-titles.nix {};

      catppuccin-cursors = pkgs.catppuccin-cursors.overrideAttrs (oldAttrs: {
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "cursors";
          rev = "47de593602cd78ffd0d659fbe8b61b3e9f13eefe";
          hash = "sha256-LHYiw9QYws8Iz5RJenMLiawPiNTMnGxjevcDk5ZY1uc=";
        };

        nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [pkgs.zip];

        outputs = ["mochaDark" "out"];

        buildPhase = ''
          runHook preBuild

          patchShebangs .

          just clean
          just build mocha dark

          runHook postBuild
        '';
      });
    };
  in {
    packages = lib.attrsets.filterAttrs (_: v: builtins.elem system v.meta.platforms) _packages;

    overlayAttrs = let
      _1passwordPreFixup = ''
        makeShellWrapper "$out"/share/1password/1password "$out"/bin/1password \
          "''${gappsWrapperArgs[@]}" \
          --suffix PATH : ${lib.makeBinPath [pkgs.xdg-utils]} \
          --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [pkgs.udev]} \
          --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --use-tray-icon}}"
      '';
    in {
      inherit
        (_packages)
        catppuccin
        catppuccin-cursors
        catppuccin-wallpapers
        cider2
        fast-syntax-highlighting
        hoppscotch-desktop-unwrapped
        hoppscotch-desktop
        inter
        monaspace
        package-version-server
        simple-completion-language-server
        vesktop
        vulkan-hdr-layer
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
      hyprcursor = inputs.hyprcursor.packages.${system}.hyprcursor.override {stdenv = pkgs.gcc14Stdenv;};
      hypridle = inputs.hypridle.packages.${system}.hypridle.override {stdenv = pkgs.gcc14Stdenv;};
      hyprland = inputs.hyprland.packages.${system}.hyprland.override {stdenv = pkgs.gcc14Stdenv;};
      hyprland-protocols = inputs.hyprland-protocols.packages.${system}.hyprland-protocols.override {stdenv = pkgs.gcc14Stdenv;};
      hyprland-qtutils = inputs.hyprland-qtutils.packages.${system}.hyprland-qtutils.override {stdenv = pkgs.gcc14Stdenv;};
      hyprlang = inputs.hyprlang.packages.${system}.hyprlang.override {stdenv = pkgs.gcc14Stdenv;};
      hyprlock = inputs.hyprlock.packages.${system}.hyprlock.override {stdenv = pkgs.gcc14Stdenv;};
      hyprgraphics = inputs.hyprgraphics.packages.${system}.hyprgraphics.override {stdenv = pkgs.gcc14Stdenv;};
      hyprpaper = inputs.hyprpaper.packages.${system}.hyprpaper.override {stdenv = pkgs.gcc14Stdenv;};
      hyprpolkitagent = inputs.hyprpolkitagent.packages.${system}.hyprpolkitagent.override {stdenv = pkgs.gcc14Stdenv;};
      hyprutils = inputs.hyprutils.packages.${system}.hyprutils.override {stdenv = pkgs.gcc14Stdenv;};
      hyprwayland-scanner = inputs.hyprwayland-scanner.packages.${system}.hyprwayland-scanner.override {stdenv = pkgs.gcc14Stdenv;};
      xdg-desktop-portal-hyprland = inputs.xdph.packages.${system}.xdg-desktop-portal-hyprland.override {stdenv = pkgs.gcc14Stdenv;};
    };
  };
}
