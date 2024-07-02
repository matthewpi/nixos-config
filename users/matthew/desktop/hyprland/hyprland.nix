{
  config,
  flavour,
  lib,
  pkgs,
  ...
}: let
  mkSystemdRun = {
    name,
    command,
    args ? null,
  }: ''${pkgs.systemd}/bin/systemd-run --user --collect --no-block --slice=app --unit="app-${name}@''${RANDOM}" ${
      if args == null
      then ""
      else ''${lib.concatStringsSep " " args} ''
    }${command}'';

  # Command used to launch alacritty.
  alacritty = mkSystemdRun {
    name = "org.alacritty.Alacritty";
    command = lib.getExe config.programs.alacritty.package;
  };

  # Command used to launch cider.
  cider = mkSystemdRun {
    name = "sh.cider.Cider";
    command = lib.getExe pkgs.cider2;
  };

  # Command used to launch discord.
  discord = mkSystemdRun {
    name = "com.discord.Discord";
    command = lib.getExe pkgs.vesktop;
  };

  # Command used to launch firefox.
  firefox = mkSystemdRun {
    name = "org.mozilla.Firefox";
    command = lib.getExe config.programs.firefox.package;
  };

  # Command used to launch slack.
  slack = mkSystemdRun {
    name = "com.slack.Slack";
    command = lib.getExe pkgs.slack;
  };

  # Command used to take a screenshot.
  screenshot = lib.getExe (pkgs.writeShellApplication {
    name = "hyprland-screenshot";
    runtimeInputs = with pkgs; [grim satty slurp wl-clipboard];
    text = ''
      grim -t png -l 6 -g "$(slurp -o -r -c '#ff0000ff')" - | satty --fullscreen --filename - --copy-command wl-copy
    '';
  });

  # Command used to set the systemd environment
  systemdEnvironment = lib.getExe (pkgs.writeShellApplication {
    name = "hyprland-systemd-environment";
    runtimeInputs = with pkgs; [dbus];
    text = ''
      (
        export PATH='/run/wrappers/bin:/nix/profile/bin:/etc/profiles/per-user/matthew/bin:/run/current-system/sw/bin'
        dbus-update-activation-environment --systemd --all
      )
    '';
  });
in {
  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;

    xwayland.enable = true;

    systemd = {
      enableXdgAutostart = true;

      extraCommands = [
        systemdEnvironment
        "${pkgs.systemd}/bin/systemctl --user stop hyprland-session.target"
        "${pkgs.systemd}/bin/systemctl --user start hyprland-session.target"
      ];

      # Add additional variables that allow desktop portals to work properly.
      variables = lib.mkDefault [
        # https://wiki.hyprland.org/Nix/Hyprland-on-Home-Manager/#programs-dont-work-in-systemd-services-but-do-on-the-terminal
        # "--all"
      ];
    };

    settings = {
      # Load catppuccin color variables so we can have a nice color scheme
      source = ["${pkgs.catppuccin}/hyprland/${flavour}.conf"];

      xwayland = {
        # https://wiki.hyprland.org/Configuring/XWayland/#hidpi-xwayland
        force_zero_scaling = true;
      };

      input = {
        kb_layout = "us";

        # Disable mouse acceleration
        accel_profile = "flat";

        # Only move keyboard focus on click
        follow_mouse = 2;

        # Only focus windows when the mouse crosses a window boundary
        # NOTE: this seems to fix issues with pop-ups in JetBrains IDEs
        mouse_refocus = false;
      };

      general = {
        # Border Colors
        "col.active_border" = "$surface1";
        "col.inactive_border" = "$surface0";

        # Use smaller window gaps
        gaps_in = 4;
        gaps_out = 12;
      };

      cursor = {
        # Disable cursor warping.
        no_warps = true;
      };

      animations = {
        # Disable animations
        enabled = false;
      };

      decoration = {
        # Round the corners of windows
        rounding = 8;

        blur = {
          # Disable window background blur
          enabled = false;
        };
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      misc = {
        # Disable auto-reloading
        disable_autoreload = true;

        # Disable logo and splash
        disable_hyprland_logo = true;
        disable_splash_rendering = true;

        # Disable the default wallpaper, we will load our own with hyprpaper.
        force_default_wallpaper = 0;

        # Wake monitors on key presses
        key_press_enables_dpms = true;

        # Focus a window on `activate`
        focus_on_activate = true;

        # Allow direct scanout
        no_direct_scanout = false;
      };

      # Monitor configuration
      monitor = [
        "DP-3, 3840x2160@240, 0x0, 1.5, vrr,0, bitdepth,8"
        "HDMI-A-1, 1920x1080@144, -1920x0, 1, vrr,0, bitdepth,8"
      ];

      workspace = [
        # Configure default workspaces for the monitors
        "1, monitor:DP-3, default:true"
        "2, monitor:HDMI-A-1, default:true"

        # Special workspaces that can be toggled on and off
        "special:terminal, on-created-empty:${alacritty}"
        "special:discord,  on-created-empty:${discord}"
        "special:slack,    on-created-empty:${slack}"
      ];

      windowrule = [
        # Dialogs
        "float, title:^(Open File)(.*)$"
        "float, title:^(Select a File)(.*)$"
        "float, title:^(Choose wallpaper)(.*)$"
        "float, title:^(Open Folder)(.*)$"
        "float, title:^(Save As)(.*)$"
        "float, title:^(Library)(.*)$"
        "float, title:^(Accounts)(.*)$"
      ];

      windowrulev2 = [
        # Fixes for JetBrains IDE pop-ups
        # ref; https://github.com/hyprwm/Hyprland/issues/1947#issuecomment-1784909413
        "windowdance, class:^(jetbrains-.*)$"
        #"dimaround, class:^(jetbrains-.*)$, floating:1, title:^(?!win)"
        "center, class:^(jetbrains-.*)$, floating:1, title:^(?!win)"
        "noanim, class:^(jetbrains-.*)$, title:^(win.*)$"
        "noinitialfocus, class:^(jetbrains-.*)$, title:^(win.*)$"
        "rounding 0, class:^(jetbrains-.*)$, title:^(win.*)$"

        # Steam
        "center, title:(Steam), class:(), floating:1"
        "float, title:(Steam Settings), class:(steam)"
        "float, title:(Friends List), class:(steam)"

        # Polkit
        #"dimaround, class:(polkit-gnome-authentication-agent-1)"
        "center,    class:(polkit-gnome-authentication-agent-1)"
        "float,     class:(polkit-gnome-authentication-agent-1)"
        "pin,       class:(polkit-gnome-authentication-agent-1)"

        # Screenshare Portal
        #"dimaround, title:(MainPicker)"
        "center,    title:(MainPicker)"
        "float,     title:(MainPicker)"
        "pin,       title:(MainPicker)"

        # Keyring
        #"dimaround, class:(gcr-prompter)"
        "center,    class:(gcr-prompter)"
        "float,     class:(gcr-prompter)"
        "pin,       class:(gcr-prompter)"

        # Float GNOME calculator
        "float, class:(org.gnome.Calculator)"

        # Disable borders on floating windows
        "noborder, floating:1"

        # Inhibit idle whenever an application is fullscreened
        "idleinhibit always, fullscreen:1"
      ];

      # Keybinds
      "$mainMod" = "Super";
      bind = [
        # Special workspace keybinds, used to toggle the workspaces on and off
        "$mainMod, C, togglespecialworkspace, terminal"
        "$mainMod, D, togglespecialworkspace, discord"
        "$mainMod, S, togglespecialworkspace, slack"

        # Special workspace keybinds, used to move windows into the workspace
        "$mainMod Shift, C, movetoworkspace, special:terminal"
        "$mainMod Shift, D, movetoworkspace, special:discord"

        # Screenshot keybind
        ", Print, exec, ${screenshot}"

        # Utility keybinds
        "$mainMod, Q, killactive"

        # Application keybinds
        "$mainMod, Space, exec, ${lib.getExe' config.programs.ags.package "ags"} --toggle-window applauncher"
        "$mainMod, P, exec, ${lib.getExe' pkgs.hyprpicker "hyprpicker"}" # Color Picker
        "$mainMod, T, exec, ${alacritty}" # Terminal
        "$mainMod, B, exec, ${firefox}" # Web Browser
        "$mainMod, M, exec, ${cider}" # Music

        # Switch workspaces with $mainMod + [0-9]
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move active window to a specific workspace with $mainMod + Shift + [0-9]
        "$mainMod Shift, 1, movetoworkspace, 1"
        "$mainMod Shift, 2, movetoworkspace, 2"
        "$mainMod Shift, 3, movetoworkspace, 3"
        "$mainMod Shift, 4, movetoworkspace, 4"
        "$mainMod Shift, 5, movetoworkspace, 5"
        "$mainMod Shift, 6, movetoworkspace, 6"
        "$mainMod Shift, 7, movetoworkspace, 7"
        "$mainMod Shift, 8, movetoworkspace, 8"
        "$mainMod Shift, 9, movetoworkspace, 9"
        "$mainMod Shift, 0, movetoworkspace, 10"

        # Mute audio
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

        # hyprlock keybinds
        #
        # hyprlock is wired up via hypridle to systemd.
        #
        # `loginctl lock-session` will launch only hyprlock,
        # while `systemctl suspend` will handle both hyprlock
        # and any other actions; such as DPMS.
        #
        # bindl allows the bind to be used even when an input inhibitor is active
        "$mainMod, L, exec, ${pkgs.systemd}/bin/loginctl lock-session"
        "$mainMod Shift, L, exec, ${pkgs.systemd}/bin/systemctl suspend"
      ];

      # bindl allows the bind to be used even when an input inhibitor is active
      bindl = [
        "$mainMod Shift, L, exec, ${pkgs.systemd}/bin/systemctl suspend"
      ];

      bindm = [
        # $mainMod + Left-click to drag window
        "$mainMod, mouse:272, movewindow"
      ];

      binde = [
        # Volume up/down
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-"
      ];
    };
  };
}
