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
  };

  perSystem = {
    lib,
    pkgs,
    system,
    ...
  }: let
    _packages = rec {
      catppuccin-wallpapers = pkgs.callPackage ./catppuccin-wallpapers/package.nix {};
      fast-syntax-highlighting = pkgs.callPackage ./fast-syntax-highlighting/package.nix {};
      freelens = pkgs.callPackage ./freelens/package.nix {inherit freelens-k8s-proxy;};
      freelens-k8s-proxy = pkgs.callPackage ./freelens-k8s-proxy/package.nix {};
      hoppscotch = pkgs.callPackage ./hoppscotch/package.nix {};
      hoppscotch-webapp-bundler = pkgs.callPackage ./hoppscotch-desktop/webapp-bundler.nix {inherit hoppscotch;};
      hoppscotch-desktop = pkgs.callPackage ./hoppscotch-desktop/package.nix {inherit hoppscotch hoppscotch-webapp-bundler;};
      inter = pkgs.callPackage ./inter/package.nix {};
      monaspace = pkgs.callPackage ./monaspace/package.nix {};
      star-citizen = pkgs.callPackage ./star-citizen {inherit inputs;};

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
          --add-flags "\''${NIXOS_OZONE_WL:+--ozone-platform-hint=auto}"
      '';
    in (_packages
      // {
        _1password-gui = pkgs._1password-gui.overrideAttrs {preFixup = _1passwordPreFixup;};
        _1password-gui-beta = pkgs._1password-gui-beta.overrideAttrs {preFixup = _1passwordPreFixup;};

        vesktop = pkgs.vesktop.override {
          withTTS = false;
          withSystemVencord = true;
        };
      });
  };
}
