{inputs, ...}: {
  imports = [
    ./hypr.nix
  ];

  flake.overlays.overrides = final: prev: {
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

    mangohud = prev.mangohud.overrideAttrs {
      patches = [
        # Add @libraryPath@ template variable to fix loading the preload
        # library and @dataPath@ to support overlaying Vulkan apps without
        # requiring MangoHud to be installed
        "${inputs.nixpkgs}/pkgs/tools/graphics/mangohud/preload-nix-workaround.patch"

        # Hard code dependencies. Can't use makeWrapper since the Vulkan
        # layer can be used without the mangohud executable by setting MANGOHUD=1.
        (final.replaceVars
          (final.fetchpatch2 {
            url = "https://raw.githubusercontent.com/NixOS/nixpkgs/62f1946374dc9d463544293244ffc596f22b5c59/pkgs/tools/graphics/mangohud/hardcode-dependencies.patch";
            hash = "sha256-E4Q/OH/eCFJKPsVlBMtm3DD5U0URKn9+LZZkNq5dCiU=";
          })
          {
            path = final.lib.makeBinPath (with final; [
              coreutils
              curl
              gnugrep
              gnused
              xdg-utils
            ]);

            inherit (final) libGL hwdata;
            inherit (final.xorg) libX11;
            libdbus = final.dbus.lib;
          })
      ];
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
