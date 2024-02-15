{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  # Enable greetd
  services.greetd = {
    enable = lib.mkDefault true;
    restart = lib.mkDefault true;
    settings = rec {
      # Configure a session for Hyprland, the greeter (regreet in this case) will use it as one of
      # the available session options. We can add additional sessions in this config if needed.
      hyprland = {
        command = "${lib.getExe config.programs.hyprland.package}";
      };

      default_session = {
        command = "${lib.getExe config.programs.hyprland.package} --config /etc/greetd/hyprland.conf";
        user = "greeter";
      };
    };
  };

  environment.etc."greetd/ags".source = ../ags/greetd;

  environment.etc."greetd/hyprland.conf".text = ''
    # Load catppuccin color variables so we can have a nice color scheme
    # TODO: map flavour
    source = ${pkgs.catppuccin}/hyprland/mocha.conf

    input {
      kb_layout = us

      # Disable mouse acceleration
      accel_profile = flat
    }

    general {
      # Border Colors
      col.active_border   = $surface1
      col.inactive_border = $surface0

      # Use smaller window gaps
      gaps_in  = 4
      gaps_out = 12
    }

    animations {
      # Disable animations
      enabled = false
    }

    decoration {
      # Round the corners of windows
      rounding = 8

      blur {
        # Disable window background blur
        enabled = false
      }
    }

    # Monitor configuration
    monitor = DP-3, 1920x1080@144, 0x0, 1, vrr,1
    monitor = HDMI-A-1, 1920x1080@60, -1920x0, 1, vrr,0

    exec-once = ${lib.getExe inputs.ags.packages.${pkgs.system}.ags} --config /etc/greetd/ags/config.js; hyprctl dispatch exit
  '';
}
