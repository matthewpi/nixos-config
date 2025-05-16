{
  services.zram-generator = {
    enable = true;
    settings.zram0 = {
      zram-size = "min(ram / 4, 16384)";
      compression-algorithm = "zstd";
    };
  };
}
