{
  inputs,
  nixosConfig,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    (prismlauncher.override {
      jdks = with pkgs; [
        temurin-jre-bin-8
        temurin-jre-bin-17
        temurin-jre-bin-21
        temurin-jre-bin-23
        temurin-jre-bin-24
      ];
    })

    (pkgs.callPackage ./star-citizen.nix {
      winetricks = inputs.nix-gaming.packages.${pkgs.system}.winetricks-git;
      wine =
        (inputs.nix-gaming.packages.${pkgs.system}.wine-tkg.override (oldAttrs: {
          patches =
            (oldAttrs.patches or [])
            ++ [
              (pkgs.fetchpatch2 {
                url = "https://raw.githubusercontent.com/starcitizen-lug/patches/98d6a9b6ce102726030bec3ee9ff63e3fad59ad5/wine/cache-committed-size.patch";
                hash = "sha256-cTO6mfKF1MJ0dbaZb76vk4A80OPakxsdoSSe4Og/VdM=";
              })
              (pkgs.fetchpatch2 {
                url = "https://raw.githubusercontent.com/starcitizen-lug/patches/98d6a9b6ce102726030bec3ee9ff63e3fad59ad5/wine/silence-sc-unsupported-os.patch";
                hash = "sha256-/PnXSKPVzSV8tzsofBFT+pNHGUbj8rKrJBg3owz2Stc=";
              })
            ];
        })).overrideDerivation (_: {
          # This is necessary in order to build Wine with NTSync7 support.
          #
          # TODO: we still need the ntsync patchset.
          NIX_CFLAGS_COMPILE = let
            headers = pkgs.makeLinuxHeaders {
              inherit (nixosConfig.boot.kernelPackages.kernel) src version patches;
            };
          in [
            "-I${headers}/include"
          ];
        });
    })
  ];

  programs.mangohud = {
    enable = true;
    settings = {
      # preset = 2;

      gpu_stats = true;
      gpu_temp = true;
      gpu_core_clock = true;
      # gpu_mem_clock = true;
      # gpu_mem_temp = true;
      gpu_power = true;
      gpu_fan = true;
      gpu_voltage = true;

      cpu_stats = true;
      cpu_temp = true;
      cpu_power = true;
      cpu_mhz = true;

      histogram = false;

      vkbasalt = true;
      winesync = true;

      font_size = 20;
      font_file = "${pkgs.inter}/share/fonts/opentype/Inter/Inter-Regular.otf";
      text_outline = false;

      background_alpha = 0.5;
      alpha = 1.0;

      position = "top-right";
      offset_x = -16;
      offset_y = 16;
    };
  };
}
