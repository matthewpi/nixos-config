{
  inputs,
  pkgs,
  ...
}: let
  nix-gaming = inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system};

  winetricks = nix-gaming.winetricks-git;
  inherit (nix-gaming) wine-mono;
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

  linuxHeaders = pkgs.makeLinuxHeaders {
    inherit (pkgs.linuxPackages_xanmod_latest.kernel) src version patches;
  };

  wine =
    (pkgs.callPackage ./wine.nix {
      inherit inputs;
      inherit wine-mono;

      src = pkgs.fetchFromGitHub {
        owner = "Kron4ek";
        repo = "wine-tkg";
        tag = "11.0-rc1";
        hash = "sha256-qfP5rxw/UBImqBawK6vAAZgyF3ayHgcEHwxIrww8+TU=";
      };

      patches = let
        patches = pkgs.fetchFromGitHub {
          owner = "starcitizen-lug";
          repo = "patches";
          rev = "3f957d856a844a8e9c9bf59a4dba2dbf0fa3f0c7";
          hash = "sha256-fCAV/w9k41sdcsZ3Df035Emw6QBSPX8XPc0tuXpALDM=";
        };
      in [
        # "${patches}/wine/0079-HACK-winewayland-add-support-for-picking-primary-mon.patch"
        # "${patches}/wine/0088-fixup-HACK-winewayland-add-support-for-picking-prima.patch"
        "${patches}/wine/append_cmd.patch"
        "${patches}/wine/cache-committed-size.patch"
        "${patches}/wine/dummy_dlls.patch"
        "${patches}/wine/eac_60101_timeout.patch"
        "${patches}/wine/eac_locale.patch"
        "${patches}/wine/enables_dxvk-nvapi.patch"
        "${patches}/wine/nvngx_dlls.patch"
        "${patches}/wine/silence-sc-unsupported-os.patch"
        "${patches}/wine/unopenable-device-is-bad.patch"
      ];
    }).overrideAttrs (oldAttrs: {
      # Include linux kernel headers for ntsync.
      buildInputs = oldAttrs.buildInputs ++ [pkgs.autoconf linuxHeaders pkgs.ffmpeg-full];
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [pkgs.autoconf];

      postPatch =
        (oldAttrs.postPatch or "")
        + ''
          echo 'Disabling winemenubuilder...'
          substituteInPlace loader/wine.inf.in --replace-warn \
            'HKLM,%CurrentVersion%\RunServices,"winemenubuilder",2,"%11%\winemenubuilder.exe -a -r"' \
            'HKLM,%CurrentVersion%\RunServices,"winemenubuilder",2,"%11%\winemenubuilder.exe -r"'

          autoreconf -f
          autoreconf -fiv
        '';
    });

  star-citizen = pkgs.callPackage ./package.nix {
    inherit wine wineprefix-preparer winetricks;
  };
in
  star-citizen
