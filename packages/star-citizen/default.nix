{
  inputs,
  pkgs,
  ...
}: let
  nix-gaming = inputs.nix-gaming.packages.${pkgs.system};

  winetricks = nix-gaming.winetricks-git;
  inherit (nix-gaming) umu-launcher;
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
        rev = "b5417fc26c586da6a58d58d74afe8843d2482168";
        hash = "sha256-cIQ80yLj0aiBLYm/9nOsOLFs474JGEjTivesISyhOpc=";
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
