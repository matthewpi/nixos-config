{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    (prismlauncher.override {
      # withWaylandGLFW = true;
      jdks = with pkgs; [
        jdk8
        semeru-bin-8
        temurin-bin-8
        jdk17
        jdk21
        temurin-bin-21
      ];
    })

    (inputs.nix-gaming.packages.${pkgs.system}.star-citizen.override {wine = inputs.nix-gaming.packages.${pkgs.system}.wine-tkg;})
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

      gamemode = true;
      vkbasalt = true;

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
