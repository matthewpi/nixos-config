{pkgs, ...}: {
  home.packages = [pkgs.supersonic-wayland];

  xdg.configFile."supersonic/themes/catppuccin-mocha-mauve.toml".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/supersonic/refs/heads/main/themes/mocha/catppuccin-mocha-mauve.toml";
    hash = "sha256-xdFyURw/0ZFi2Cd4ZX3ZDwhjVVD0Bj7j2Z/DpxhN9fo=";
  };
}
