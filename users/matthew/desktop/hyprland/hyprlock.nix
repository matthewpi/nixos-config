{
  nixosConfig,
  pkgs,
  ...
}: {
  # https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock/
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        hide_cursor = true;
        grace = 5;
        ignore_empty_input = true;

        enable_fingerprint = nixosConfig.services.fprintd.enable;
        fingerprint_ready_message = "(Scan fingerprint to unlock)";
        fingerprint_present_message = "Scanning fingerprint";
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
          text = "Hello, $USER";
          text_align = "center";
          color = "rgb(205, 214, 244)"; # Text (mocha)
          font_family = "Inter";
          font_size = 25;
          rotate = 0;
          position = "0, 80";
          halign = "center";
          valign = "center";
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "320, 64";
          outline_thickness = 4;
          dots_size = 0.33;
          dots_spacing = 0.15;
          dots_center = true;
          dots_rounding = -1;
          outer_color = "rgb(69, 71, 90)"; # Surface 1 (mocha)
          inner_color = "rgb(88, 91, 112)"; # Surface 2 (mocha)
          font_color = "rgb(205, 214, 244)"; # Text (mocha)
          fade_on_empty = false;
          fade_timeout = 1000;
          placeholder_text = "<i>Enter your password...</i>";
          hide_input = false;
          rounding = -1;
          check_color = "rgb(250, 179, 135)"; # Peach (mocha)
          fail_color = "rgb(243, 139, 168)"; # Red (mocha)
          fail_transition = 300;
          capslock_color = "-1";
          numlock_color = "-1";
          bothlock_color = "-1";
          invert_numlock = false;
          swap_font_color = false;

          position = "0, -20";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
