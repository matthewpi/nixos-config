{pkgs, ...}: {
  # https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock/
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        disable_loading_bar = false;
        hide_cursor = true;
        grace = 10;
        no_fade_in = false;
      };

      background = [
        {
          monitor = ""; # All monitors
          path = "${pkgs.catppuccin-wallpapers}/nix-black-4k.png";
          # Blur the background
          blur_passes = 2;
          # Dim the background so we can tell the difference when the system is locked.
          brightness = 0.5;
        }
      ];

      label = [
        {
          monitor = "";
          font_family = "Inter";
        }
      ];
    };
  };
}
