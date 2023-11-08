{
  programs.gamemode.enable = true;

  boot.kernel.sysctl = {
    # SteamOS/Fedora default, can help with performance.
    "vm.max_map_count" = 2147483642;
  };
}
