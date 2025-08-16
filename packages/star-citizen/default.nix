{
  inputs,
  pkgs,
  ...
}: let
  nix-gaming = inputs.nix-gaming.packages.${pkgs.system};

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

      # ntsync branch
      src = pkgs.fetchFromGitHub {
        owner = "Kron4ek";
        repo = "wine-tkg";
        rev = "956fb6d3774a2b2bac54b22c4edd3d00f961e7ba";
        hash = "sha256-WpO1CvKkE/ywJlSMEZc6sQHnrptf+qBu1aBnOEZMr9A=";
      };

      patches = let
        patches = pkgs.fetchFromGitHub {
          owner = "starcitizen-lug";
          repo = "patches";
          rev = "87a620ee062812d640fc8b8d01c39293b8fd4f60";
          hash = "sha256-/j/pmPQHSq460Iei8uqPJmNNKikDQhO7zCJJPkpX3tw=";
        };
      in [
        "${patches}/wine/append_cmd.patch"
        "${patches}/wine/cache-committed-size.patch"
        "${patches}/wine/dummy_dlls.patch"
        "${patches}/wine/real_path.patch"
        "${patches}/wine/silence-sc-unsupported-os.patch"
        "${patches}/wine/printkey_wld.patch"
        # "${patches}/wine/winewayland-no-enter-move-if-relative.patch"
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
