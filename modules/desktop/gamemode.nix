{
  # Enable gamemode and the gamemoded service.
  programs.gamemode.enable = true;
  systemd.user.services.gamemoded.serviceConfig.Slice = "background.slice";

  boot.kernel.sysctl = {
    # SteamOS/Fedora default, can help with performance.
    "vm.max_map_count" = 2147483642;
  };
}
