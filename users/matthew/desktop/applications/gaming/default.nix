{pkgs, ...}: {
  home.packages = [
    (pkgs.prismlauncher.override {
      controllerSupport = false;
      gamemodeSupport = false;
      textToSpeechSupport = false;
      jdks = with pkgs; [
        temurin-jre-bin-8
        temurin-jre-bin-17
        temurin-jre-bin-21
        temurin-jre-bin-25
      ];
    })
  ];

  programs.mangohud = {
    enable = true;
    settings = {
      gpu_stats = true;
      gpu_temp = true;
      gpu_core_clock = true;
      gpu_mem_clock = true;
      gpu_mem_temp = true;
      gpu_power = true;
      gpu_fan = true;
      gpu_voltage = true;

      cpu_stats = true;
      cpu_temp = true;
      cpu_power = true;
      cpu_mhz = true;

      vram = true;
      ram = true;

      histogram = false;

      winesync = true;

      font_size = 20;
      font_file = "${pkgs.inter}/share/fonts/opentype/Inter/Inter-Regular.otf";
      text_outline = false;

      background_alpha = 0.5;
      alpha = 1.0;

      position = "top-right";
      offset_x = -16;
      offset_y = 16;

      font_scale = 1.5;
    };
  };
}
