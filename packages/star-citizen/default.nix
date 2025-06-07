{
  inputs,
  pkgs,
  ...
}: let
  nix-gaming = inputs.nix-gaming.packages.${pkgs.system};

  winetricks = nix-gaming.winetricks-git;
  inherit (nix-gaming) wineprefix-preparer umu-launcher;

  linuxHeaders = pkgs.makeLinuxHeaders {inherit (pkgs.linuxPackages_xanmod_latest.kernel) src version patches;};

  wine =
    (pkgs.callPackage ./wine.nix {
      inherit inputs;

      # ntsync branch
      src = pkgs.fetchFromGitHub {
        owner = "Kron4ek";
        repo = "wine-tkg";
        rev = "114d078407e75f1bb9a3ea187799cfcf6583a159";
        hash = "sha256-tcrNMiXNfBY0IZtCSucIXbfFLCvEprPtymOXMfKnHRU=";
      };

      patches = [
        (pkgs.fetchpatch2 {
          url = "https://raw.githubusercontent.com/starcitizen-lug/patches/98d6a9b6ce102726030bec3ee9ff63e3fad59ad5/wine/cache-committed-size.patch";
          hash = "sha256-cTO6mfKF1MJ0dbaZb76vk4A80OPakxsdoSSe4Og/VdM=";
        })
        (pkgs.fetchpatch2 {
          url = "https://raw.githubusercontent.com/starcitizen-lug/patches/98d6a9b6ce102726030bec3ee9ff63e3fad59ad5/wine/silence-sc-unsupported-os.patch";
          hash = "sha256-/PnXSKPVzSV8tzsofBFT+pNHGUbj8rKrJBg3owz2Stc=";
        })
      ];
    }).overrideAttrs (oldAttrs: {
      # Include linux kernel headers for ntsync.
      buildInputs = oldAttrs.buildInputs ++ [linuxHeaders];

      # Fix `winetricks` by ensuring a `wine64` binary exists.
      postInstall =
        (oldAttrs.postInstall or "")
        + ''
          ln -s "$out"/bin/wine "$out"/bin/wine64
        '';
    });
in
  pkgs.callPackage ./package.nix {
    inherit wine wineprefix-preparer winetricks umu-launcher;
  }
