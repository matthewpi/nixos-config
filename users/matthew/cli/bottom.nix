{
  flavour,
  pkgs,
  ...
}: {
  programs.bottom = {
    enable = true;
  };

  xdg.configFile."bottom/bottom.toml".source = "${pkgs.catppuccin}/bottom/${flavour}.toml";
}
