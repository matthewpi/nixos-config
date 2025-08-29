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
      cider2 = pkgs.callPackage ./cider2 {};
      fast-syntax-highlighting = pkgs.callPackage ./fast-syntax-highlighting/package.nix {};
      freelens = pkgs.callPackage ./freelens/package.nix {inherit freelens-k8s-proxy;};
      freelens-k8s-proxy = pkgs.callPackage ./freelens-k8s-proxy/package.nix {};
      hoppscotch = pkgs.callPackage ./hoppscotch/package.nix {};
      hoppscotch-webapp-bundler = pkgs.callPackage ./hoppscotch-desktop/webapp-bundler.nix {inherit hoppscotch;};
      hoppscotch-desktop = pkgs.callPackage ./hoppscotch-desktop/package.nix {inherit hoppscotch hoppscotch-webapp-bundler;};
      inter = pkgs.callPackage ./inter/package.nix {};
      monaspace = pkgs.callPackage ./monaspace/package.nix {};
      simple-completion-language-server = pkgs.callPackage ./simple-completion-language-server/package.nix {};
      star-citizen = pkgs.callPackage ./star-citizen {inherit inputs;};
      tailscale = pkgs.callPackage ./tailscale/package.nix {};
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

        discord =
          (pkgs.discord.override {
            withOpenASAR = true;
            withMoonlight = true;
            withTTS = false;
          }).overrideAttrs rec {
            version = "0.0.104";
            src = pkgs.fetchurl {
              url = "https://stable.dl2.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
              hash = "sha256-4w8C9YHRNTgkUBzqkW1IywKtRHvtlkihjo3/shAgPac=";
            };
          };
      });
  };
}
