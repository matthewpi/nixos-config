{inputs, ...}: {
  imports = [
    ./hypr.nix
  ];

  flake.overlays.overrides = _: prev: {
    # Only build mochaDark cursors so the build doesn't take 8 years to build
    # a bunch of cursors we won't end up using anyways.
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
      catppuccin = pkgs.callPackage ./catppuccin {};
      catppuccin-wallpapers = pkgs.callPackage ./catppuccin/wallpapers {};
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

      # This is here instead of an overlay since it's a new package based on an existing one.
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
    in (_packages
      // {
        _1password-gui = pkgs._1password-gui.overrideAttrs (_: {preFixup = _1passwordPreFixup;});
        _1password-gui-beta = pkgs._1password-gui-beta.overrideAttrs (_: {preFixup = _1passwordPreFixup;});

        discord =
          (pkgs.discord.override {
            withOpenASAR = true;
            withMoonlight = true;
            withTTS = false;
          }).overrideAttrs rec {
            version = "0.0.94";

            src = pkgs.fetchurl {
              url = "https://stable.dl2.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
              hash = "sha256-035nfbEyvdsNxZh6fkXh2JhY7EXQtwUnS4sUKr74MRQ=";
            };
          };

        mesa = pkgs.mesa.overrideAttrs (oldAttrs: {
          patches =
            (oldAttrs.patches or [])
            ++ [
              # https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/34918
              (pkgs.fetchpatch2 {
                url = "https://raw.githubusercontent.com/Nobara-Project/rpm-sources/refs/heads/42/baseos/mesa/34918.patch";
                hash = "sha256-TbospUjVyC6GkctnEUpSMXKB8PX6mU0GG086tSph0Fc=";
              })
            ];
        });
      });
  };
}
