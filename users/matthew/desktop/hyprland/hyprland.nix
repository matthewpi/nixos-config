{
  config,
  flavour,
  lib,
  pkgs,
  ...
}: let
  alacritty = lib.getExe config.programs.alacritty.package;
  discord = lib.getExe pkgs.vesktop;
  firefox = lib.getExe pkgs.firefox; # TODO: from config
  slack = lib.getExe pkgs.slack;

  # Command used to take a screenshot.
  screenshot = lib.getExe (pkgs.writeShellApplication {
    name = "hyprland-screenshot";
    runtimeInputs = with pkgs; [grim satty slurp wl-clipboard];
    text = ''
      grim -t png -l 6 -g "$(slurp -o -r -c '#ff0000ff')" - | satty --fullscreen --filename - --copy-command wl-copy
    '';
  });
in {
  home.sessionVariables = {
    XDG_SESSION_DESKTOP = "Hyprland";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  wayland.windowManager.hyprland = {
    enable = true;

    # Add additional variables that allow desktop portals to work properly.
    systemd.variables = lib.mkDefault [
      # https://github.com/hyprwm/hypridle/issues/20#issuecomment-1964160720
      "--all"
      ## These four options are the defaults.
      #"DISPLAY"
      #"HYPRLAND_INSTANCE_SIGNATURE"
      #"WAYLAND_DISPLAY"
      #"XDG_CURRENT_DESKTOP"
      #
      ## Fixes issues with `xdg-open`
      #"BROWSER"
      ## Fixes issues with `gio mime`
      #"PATH"
    ];

    extraConfig = ''
      # Load catppuccin color variables so we can have a nice color scheme
      source = ${pkgs.catppuccin}/hyprland/${flavour}.conf

      input {
        kb_layout = us

        # Disable mouse acceleration
        accel_profile = flat

        # Only move keyboard focus on click
        follow_mouse = 2

        # Only focus windows when the mouse crosses a window boundary
        # NOTE: this seems to fix issues with pop-ups in JetBrains IDEs
        mouse_refocus = false
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

      dwindle {
        pseudotile = true
        preserve_split = true
      }

      misc {
        # Disable auto-reloading
        disable_autoreload = true

        # Disable logo and splash
        disable_hyprland_logo = true
        disable_splash_rendering = true

        # Disable the default wallpaper, we will load our own with hyprpaper.
        force_default_wallpaper = 0

        # Wake monitors on key presses
        key_press_enables_dpms = true

        # Focus a window on `activate`
        focus_on_activate = true

        # Allow direct scanout
        no_direct_scanout = false
      }

      # Start hyprpaper
      # TODO: can we do this under systemd?
      exec-once = ${lib.getExe pkgs.hyprpaper}

      # Dialogs
      windowrule = float, title:^(Open File)(.*)$
      windowrule = float, title:^(Select a File)(.*)$
      windowrule = float, title:^(Choose wallpaper)(.*)$
      windowrule = float, title:^(Open Folder)(.*)$
      windowrule = float, title:^(Save As)(.*)$
      windowrule = float, title:^(Library)(.*)$
      windowrule = float, title:^(Accounts)(.*)$

      # Gamescope
      #windowrulev2 = fakefullscreen, class:(.gamescope-wrapped)
      #windowrulev2 = size 100%, class:(.gamescope-wrapped)
      #windowrulev2 = tile, class:(.gamescope-wrapped)

      # Fixes for JetBrains IDE pop-ups
      # ref; https://github.com/hyprwm/Hyprland/issues/1947#issuecomment-1784909413
      windowrulev2 = windowdance, class:^(jetbrains-.*)$
      windowrulev2 = dimaround, class:^(jetbrains-.*)$, floating:1, title:^(?!win)
      windowrulev2 = center, class:^(jetbrains-.*)$, floating:1, title:^(?!win)
      windowrulev2 = noanim, class:^(jetbrains-.*)$, title:^(win.*)$
      windowrulev2 = noinitialfocus, class:^(jetbrains-.*)$, title:^(win.*)$
      windowrulev2 = rounding 0, class:^(jetbrains-.*)$, title:^(win.*)$

      # Steam
      windowrulev2 = center, title:(Steam), class:(), floating:1
      windowrulev2 = float, title:(Steam Settings), class:(steam)

      # Disable borders on floating windows
      windowrulev2 = noborder, floating:1

      # Inhibit idle whenever an application is fullscreened
      windowrulev2 = idleinhibit always, fullscreen:1

      # Monitor configuration
      monitor = DP-3, 1920x1080@144, 0x0, 1, vrr,1
      monitor = HDMI-A-1, 1920x1080@60, -1920x0, 1, vrr,0

      # Configure default workspaces for the monitors
      workspace = 1, monitor:DP-3, default:true
      workspace = 2, monitor:HDMI-A-1, default:true

      # Special workspaces that can be toggled on and off
      workspace = special:terminal, on-created-empty:${alacritty}
      workspace = special:discord,  on-created-empty:${discord}
      workspace = special:slack,    on-created-empty:${slack}

      # Keybinds
      $mainMod = Super

      # Special workspace keybinds, used to toggle the workspaces on and off
      bind = $mainMod, C, togglespecialworkspace, terminal
      bind = $mainMod, D, togglespecialworkspace, discord
      bind = $mainMod, S, togglespecialworkspace, slack

      bind = , Print, exec, ${screenshot}

      # swaylock keybinds
      #
      # swaylock is wired up via swayidle to systemd.
      #
      # `loginctl lock-session` will launch only swaylock,
      # while `systemctl suspend` will handle both swaylock
      # and any other actions; such as DPMS.
      #
      # bindl allows the bind to be used even when an input inhibitor is active
      bind  = $mainMod, L, exec, ${pkgs.systemd}/bin/loginctl lock-session
      bind  = $mainMod Shift, L, exec, ${pkgs.systemd}/bin/systemctl suspend
      bindl = $mainMod Shift, L, exec, ${pkgs.systemd}/bin/systemctl suspend

      # Utility keybinds
      bind = $mainMod, Q, killactive

      # Application keybinds
      bind = $mainMod, Space, exec, ${lib.getExe' config.programs.anyrun.package "anyrun"} # App Launcher
      bind = $mainMod, P, exec, ${lib.getExe' pkgs.hyprpicker "hyprpicker"} # Color Picker
      bind = $mainMod, T, exec, ${alacritty} # Terminal
      bind = $mainMod, B, exec, ${firefox} # Web Browser

      # $mainMod + Left-click to drag window
      bindm = $mainMod, mouse:272, movewindow

      # Switch workspaces with $mainMod + [0-9]
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $mainMod, 0, workspace, 10

      # Move active window to a specific workspace with $mainMod + Shift + [0-9]
      bind = $mainMod Shift, 1, movetoworkspace, 1
      bind = $mainMod Shift, 2, movetoworkspace, 2
      bind = $mainMod Shift, 3, movetoworkspace, 3
      bind = $mainMod Shift, 4, movetoworkspace, 4
      bind = $mainMod Shift, 5, movetoworkspace, 5
      bind = $mainMod Shift, 6, movetoworkspace, 6
      bind = $mainMod Shift, 7, movetoworkspace, 7
      bind = $mainMod Shift, 8, movetoworkspace, 8
      bind = $mainMod Shift, 9, movetoworkspace, 9
      bind = $mainMod Shift, 0, movetoworkspace, 10

      # Audio keybinds (via wireplumber)
      binde =, XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
      binde =, XF86AudioLowerVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-
      bind  =, XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    '';
  };
}
