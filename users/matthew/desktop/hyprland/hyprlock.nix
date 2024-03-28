{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.hyprlock.homeManagerModules.default
  ];

  # https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock/
  programs.hyprlock = {
    enable = true;
    package = pkgs.hyprlock;

    general = {
      disable_loading_bar = false;
      hide_cursor = true;
      grace = 10;
      no_fade_in = false;
    };

    backgrounds = [
      {
        monitor = ""; # All monitors
        path = "${pkgs.catppuccin-wallpapers}/nix-black-4k.png";
        # Blur the background
        blur_passes = 2;
        # Dim the background so we can tell the difference when the system is locked.
        brightness = 0.5;
      }
    ];

    labels = [
      {
        monitor = "";
        font_family = "Inter";
      }
    ];
  };
}
