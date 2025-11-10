{
  inputs,
  pkgs,
  ...
}: let
  nix-gaming = inputs.nix-gaming.packages."${pkgs.stdenv.hostPlatform.system}";

  winetricks = nix-gaming.winetricks-git;
  wineprefix-preparer = pkgs.callPackage ./wineprefix-preparer.nix {
    inherit
      (nix-gaming)
      dxvk-w32
      dxvk-w64
      dxvk-nvapi-w32
      dxvk-nvapi-w64
      vkd3d-proton-w32
      vkd3d-proton-w64
      ;
  };

  linuxHeaders = pkgs.makeLinuxHeaders {inherit (pkgs.linuxPackages_xanmod_latest.kernel) src version patches;};

  wine =
    (pkgs.callPackage ./wine.nix {
      inherit inputs;

      src = pkgs.fetchFromGitHub {
        owner = "Kron4ek";
        repo = "wine-tkg";
        tag = "10.17";
        hash = "sha256-/diEOe6uPquBhffpDEx5NofEBGcXzFVCJsxAkOyGiNI=";
      };

      patches = let
        patches = pkgs.fetchFromGitHub {
          owner = "starcitizen-lug";
          repo = "patches";
          rev = "16908d0748f7d1b706f41fc17e18fafe84dced5b";
          hash = "sha256-SF6RV1NZWtXJ9zWVy9WSiioeHr0Gi2Zpx1GNqLZGQWc=";
        };
      in [
        "${patches}/wine/append_cmd.patch"
        "${patches}/wine/cache-committed-size.patch"
        "${patches}/wine/dummy_dlls.patch"
        "${patches}/wine/eac_60101_timeout.patch"
        "${patches}/wine/real_path.patch"
        "${patches}/wine/printkey_wld.patch"
        "${patches}/wine/silence-sc-unsupported-os.patch"
      ];
    }).overrideAttrs (oldAttrs: {
      # Include linux kernel headers for ntsync.
      buildInputs = oldAttrs.buildInputs ++ [linuxHeaders];

      prePatch =
        (oldAttrs.prePatch or "")
        + ''
          echo 'Disabling wine menubuilder...'
          substituteInPlace "loader/wine.inf.in" --replace-warn \
            'HKLM,%CurrentVersion%\RunServices,"winemenubuilder",2,"%11%\winemenubuilder.exe -a -r"' \
            'HKLM,%CurrentVersion%\RunServices,"winemenubuilder",2,"%11%\winemenubuilder.exe -r"'
        '';

      # Fix `winetricks` by ensuring a `wine64` binary exists.
      postInstall =
        (oldAttrs.postInstall or "")
        + ''
          ln -s "$out"/bin/wine "$out"/bin/wine64
        '';
    });

  star-citizen = pkgs.callPackage ./package.nix {
    inherit wine wineprefix-preparer winetricks;
  };
in
  star-citizen
