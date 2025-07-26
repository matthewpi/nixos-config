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
        rev = "2a59efcc00604b4082bed837c5a78676d5c585cd";
        hash = "sha256-qkqdz5XyZf8kBOJK6O1HtIbzqoj5sF5IzU+EOoj+ygw=";
      };

      patches = let
        patches = pkgs.fetchFromGitHub {
          owner = "starcitizen-lug";
          repo = "patches";
          rev = "db778f958c6425fd5b7f56d11bf9cdfc4f67e839";
          hash = "sha256-wW9z4JBq0/3zgLX7Y1lbReMvbLL9MDcrtGSpPvsYVg8=";
        };
      in [
        "${patches}/wine/append_cmd.patch"
        "${patches}/wine/cache-committed-size.patch"
        "${patches}/wine/dummy_dlls.patch"
        "${patches}/wine/real_path.patch"
        "${patches}/wine/silence-sc-unsupported-os.patch"
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
