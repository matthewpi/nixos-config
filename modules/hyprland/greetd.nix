{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  # Enable greetd
  services.greetd = {
    enable = lib.mkDefault true;
    restart = lib.mkDefault true;
    settings = let
      hyprland = lib.getExe config.home-manager.users.matthew.wayland.windowManager.hyprland.finalPackage;
    in {
      # Configure a session for Hyprland, the greeter (regreet in this case) will use it as one of
      # the available session options. We can add additional sessions in this config if needed.
      hyprland = {
        command = hyprland;
      };

      default_session = {
        command = hyprland;
        user = "matthew";
      };

      #default_session = {
      #  command = "${hyprland} --config /etc/greetd/hyprland.conf";
      #  user = "greeter";
      #};
    };
  };

  environment.etc."greetd/ags".source = ../ags/greetd;

  environment.etc."greetd/hyprland.conf".text = ''
    # Load catppuccin color variables so we can have a nice color scheme
    # TODO: map flavour
    source = ${pkgs.catppuccin}/hyprland/mocha.conf

    xwayland {
      # https://wiki.hyprland.org/Configuring/XWayland/#hidpi-xwayland
      force_zero_scaling = true
    }

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
    # TODO: re-use user-level monitor configuration.
    monitor = DP-3, 3840x2160@240, 0x0, 1.5, vrr,0
    monitor = HDMI-A-1, 1920x1080@144, -1920x0, 1, vrr,0

    exec-once = ${lib.getExe' inputs.ags.packages.${pkgs.system}.ags "ags"} --config /etc/greetd/ags/config.js; hyprctl dispatch exit
  '';
}
