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
      catppuccin = pkgs.callPackage ./catppuccin {};
      catppuccin-wallpapers = pkgs.callPackage ./catppuccin/wallpapers {};
      cider2 = pkgs.callPackage ./cider2 {};
      hoppscotch = pkgs.callPackage ./hoppscotch/package.nix {};
      hoppscotch-desktop = pkgs.callPackage ./hoppscotch-desktop/package.nix {inherit hoppscotch;};
      simple-completion-language-server = pkgs.callPackage ./simple-completion-language-server {};
      fast-syntax-highlighting = pkgs.callPackage ./zsh/fast-syntax-highlighting.nix {};
      inter = pkgs.callPackage ./inter.nix {};
      monaspace = pkgs.callPackage ./monaspace.nix {};
      # vesktop = pkgs.callPackage ./vesktop/package.nix {
      #   inherit inputs;
      #   vesktop = inputs.nixpkgs.legacyPackages.${system}.vesktop;
      # };
      vesktop = inputs.nixpkgs.legacyPackages.${system}.vesktop.override {
        withTTS = false;
        withSystemVencord = true;
      };
      vulkan-hdr-layer = pkgs.callPackage ./vulkan-hdr-layer {};

      catppuccin-cursors = inputs.nixpkgs.legacyPackages.${system}.catppuccin-cursors.overrideAttrs (_: {
        outputs = ["mochaDark" "out"];

        buildPhase = ''
          runHook preBuild

          patchShebangs .

          just clean
          just build mocha dark

          runHook postBuild
        '';
      });

      tailscale-systray = pkgs.tailscale.overrideAttrs (oldAttrs: rec {
        doCheck = false;
        outputs = ["out"];
        subPackages = ["cmd/systray"];
        postInstall = ''
          mv "$out"/bin/systray "$out"/bin/${meta.mainProgram}
        '';
        meta = oldAttrs.meta // {mainProgram = "tailscale-systray";};
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
          --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-wayland-ime=true}}"
      '';
    in {
      inherit
        (_packages)
        catppuccin
        catppuccin-cursors
        catppuccin-wallpapers
        cider2
        fast-syntax-highlighting
        hoppscotch-desktop
        inter
        monaspace
        simple-completion-language-server
        tailscale-systray
        # vesktop
        vulkan-hdr-layer
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
