{inputs, ...}: {
  imports = [
    ./hypr.nix
  ];

  flake.overlays.overrides = _: prev: {
    # Only build mochaDark cursors so the build doesn't take 8 years.
    catppuccin-cursors = prev.catppuccin-cursors.overrideAttrs {
      outputs = ["mochaDark" "out"];
      buildPhase = ''
        runHook preBuild
        patchShebangs .
        just clean
        just build mocha dark
        runHook postBuild
      '';
    };

    lowdown = prev.lowdown.overrideAttrs {patches = [];};
  };

  perSystem = {
    lib,
    pkgs,
    system,
    ...
  }: let
    _packages = rec {
      catppuccin-wallpapers = pkgs.callPackage ./catppuccin-wallpapers/package.nix {};
      delve-shim-dap = pkgs.callPackage ./delve-shim-dap/package.nix {};
      fluxer = pkgs.callPackage ./fluxer/package.nix {};
      freelens = pkgs.callPackage ./freelens/package.nix {inherit freelens-k8s-proxy;};
      freelens-k8s-proxy = pkgs.callPackage ./freelens-k8s-proxy/package.nix {};
      inter = pkgs.callPackage ./inter/package.nix {};
      monaspace = pkgs.callPackage ./monaspace/package.nix {};
      proton-ge-bin = pkgs.callPackage ./proton-ge-bin/package.nix {};
      star-citizen = pkgs.callPackage ./star-citizen {inherit inputs proton-ge-bin;};

      libvirt = pkgs.libvirt.override {
        enableXen = false;
        enableZfs = false;
      };

      libvirt-glib = pkgs.libvirt-glib.override {
        inherit libvirt;
      };

      virt-manager = pkgs.virt-manager.override {
        inherit libvirt-glib;
        spiceSupport = false;
      };
    };
  in {
    packages = lib.attrsets.filterAttrs (_: v: builtins.elem system v.meta.platforms) _packages;

    overlayAttrs = let
      _1passwordPreFixup = ''
        makeShellWrapper "$out"/share/1password/1password "$out"/bin/1password \
          "''${gappsWrapperArgs[@]}" \
          --suffix PATH : ${lib.makeBinPath [pkgs.xdg-utils]} \
          --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [pkgs.udev]} \
          --add-flags '--ozone-platform=wayland --ozone-platform-hint=auto'
      '';
    in (_packages
      // {
        _1password-gui = pkgs._1password-gui.overrideAttrs {preFixup = _1passwordPreFixup;};
        _1password-gui-beta = pkgs._1password-gui-beta.overrideAttrs {preFixup = _1passwordPreFixup;};

        vesktop =
          (pkgs.vesktop.override {
            withTTS = false;
            withSystemVencord = true;
          }).overrideAttrs {
            postFixup =
              lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''
                makeWrapper ${lib.getExe pkgs.electron} "$out"/bin/vesktop \
                  --add-flags "$out"/opt/Vesktop/resources/app.asar \
                  --add-flags '--ozone-platform=wayland --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true'
              ''
              + lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
                makeWrapper "$out"/Applications/Vesktop.app/Contents/MacOS/Vesktop "$out"/bin/vesktop
              '';
          };
      });
  };
}
