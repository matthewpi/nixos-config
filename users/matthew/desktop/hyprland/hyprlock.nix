{
  lib,
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
      };

      auth = {
        pam = {
          enabled = true;
          module = "hyprlock";
        };

        fingerprint = {
          enabled = nixosConfig.services.fprintd.enable;
          ready_message = "(Scan fingerprint to unlock)";
          present_message = "Scanning fingerprint";
        };
      };

      background = [
        {
          monitor = ""; # All monitors
          path = "${pkgs.catppuccin-wallpapers}/CatppuccinMocha-Kurzgesagt-CloudyQuasar1.png";
          # Blur the background
          blur_passes = 2;
          # Dim the background so we can tell the difference when the system is locked.
          brightness = 0.5;
        }
      ];

      label =
        [
          {
            monitor = "";
            # TODO: how can we get this?
            text = "cmd[update:60000] date '+%A, %B %d'";
            # text = "Saturday, December 28th";
            text_align = "center";
            color = "$text";
            font_family = "Inter";
            font_size = 24;
            rotate = 0;
            position = "0, -104";
            halign = "center";
            valign = "top";
          }
          {
            monitor = "";
            text = "$TIME";
            text_align = "center";
            color = "$text";
            font_family = "Inter, Semibold";
            font_size = 120;
            rotate = 0;
            position = "0, -128";
            halign = "center";
            valign = "top";
          }
        ]
        ++ lib.optional nixosConfig.services.fprintd.enable
        {
          monitor = "";
          text = "$FPRINTMESSAGE";
          text_align = "center";
          color = "$subtext0";
          font_family = "Inter";
          font_size = 20;
          rotate = 0;
          position = "0, 80";
          halign = "center";
          valign = "bottom";
        };

      input-field = [
        {
          monitor = "";
          size = "320, 64";
          outline_thickness = 4;
          dots_size = 0.33;
          dots_spacing = 0.15;
          dots_center = true;
          dots_rounding = -1;
          outer_color = "$surface1";
          inner_color = "$surface2";
          font_color = "$text";
          fade_on_empty = false;
          fade_timeout = 1000;
          placeholder_text = "<i>Enter your password...</i>";
          hide_input = false;
          rounding = -1;
          check_color = "$accent";
          fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
          fail_color = "$red";
          fail_transition = 300;
          capslock_color = "-1";
          numlock_color = "-1";
          bothlock_color = "-1";
          invert_numlock = false;
          swap_font_color = false;

          position = "0, 128";
          halign = "center";
          valign = "bottom";
        }
      ];
    };
  };
}
