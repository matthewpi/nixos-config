{lib, ...}: {
  # Enable gamemode and the gamemoded service.
  programs.gamemode = {
    enable = lib.mkDefault true;
    enableRenice = true;
    settings = {
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high";
      };
    };
  };
  systemd.user.services.gamemoded.serviceConfig.Slice = "background.slice";

  boot.kernel.sysctl = {
    # SteamOS/Fedora default, can help with performance.
    "vm.max_map_count" = lib.mkForce 2147483642;
  };
}
