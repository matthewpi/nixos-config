{
  config,
  isDesktop,
  lib,
  nixosConfig,
  outputs,
  pkgs,
  ...
}: let
  systemd = nixosConfig.systemd.package;

  # https://systemd.io/DESKTOP_ENVIRONMENTS/#xdg-standardization-for-applications
  mkSystemdRun = {
    name ? null,
    command,
    args ? null,
    slice ? "app-graphical",
  }:
    lib.concatStringsSep " " (
      [
        (lib.getExe' systemd "systemd-run")
        "--user"
        "--collect"
        "--no-block"
      ]
      ++ lib.optional (slice != null) "--slice=${slice}"
      ++ lib.optional (slice != null && name != null) "--unit='${slice}-${name}@'\"\${RANDOM}\""
      ++ lib.optionals (args != null) args
      ++ [command]
    );

  lock = mkSystemdRun {
    command = "${lib.getExe' systemd "loginctl"} lock-session";
    slice = null;
  };

  # Command used to launch alacritty.
  alacritty = mkSystemdRun {
    name = "org.alacritty.Alacritty";
    command = lib.getExe config.programs.alacritty.package;
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
    command = "${lib.getExe pkgs.slack} --disable-gpu";
  };

  # Command used to launch supersonic.
  supersonic = mkSystemdRun {
    name = "Supersonic";
    command = lib.getExe pkgs.supersonic-wayland;
  };

  # Command used to launch Zed.
  zed-editor = mkSystemdRun {
    name = "dev.zed.Zed";
    command = lib.getExe config.programs.zed-editor.package;
    args = ["--property=Type=forking"];
  };

  # Command used to take a screenshot.
  screenshot = lib.getExe (pkgs.writeShellApplication {
    name = "hyprland-screenshot";
    runtimeInputs = with pkgs; [grim satty slurp wl-clipboard];
    text = ''
      grim -t png -l 0 -g "$(slurp -o -r -c '#ff0000ff')" - | satty --fullscreen --filename - --copy-command wl-copy
    '';
  });

  screenshot-activeworkspace = lib.getExe (pkgs.writeShellApplication {
    name = "hyprland-screenshot-activeworkspace";
    runtimeInputs = with pkgs; [grim jq satty slurp wl-clipboard];
    text = ''
      grim -t png -l 0 -o "$(hyprctl -j activeworkspace | jq -r '.monitor')" - | satty --fullscreen --filename - --copy-command wl-copy
    '';
  });

  screenshot-selectwindow = lib.getExe (pkgs.writeShellApplication {
    name = "hyprland-screenshot-selectwindow";
    runtimeInputs = with pkgs; [grim jq satty slurp wl-clipboard];
    text = ''
      activeWorkspaces=$(hyprctl -j monitors | jq -r '[.[] | .activeWorkspace.id, .specialWorkspace.id] | join(",")')
      locations="$(hyprctl -j clients | jq -r '[.[] | select(.workspace as $w | ['"$activeWorkspaces"'] | index($w.id)) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"] | unique | .[]')"
      grim -t png -l 0 -g "$(echo "$locations" | slurp -r -c '#ff0000ff')" - | satty --fullscreen --filename - --copy-command wl-copy
    '';
  });
in {
  home.sessionVariables =
    {
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
    }
    // lib.optionalAttrs isDesktop {
      AMD_DEBUG = "lowlatencyenc";
    };

  wayland.windowManager.hyprland = {
    enable = true;

    # Set the Hyprland and XDPH packages to `null` to use the ones from the NixOS module.
    package = null;
    portalPackage = null;

    xwayland.enable = nixosConfig.programs.hyprland.xwayland.enable;
    systemd = {
      enable = !nixosConfig.programs.uwsm.enable;
      enableXdgAutostart = true;
      variables = ["--all"];
    };

    settings = {
      # Always report HDR mode as preferred.
      #
      # ref; https://wiki.hypr.land/Configuring/Variables/#quirks
      quirks.prefer_hdr = 1;

      # https://wiki.hyprland.org/Configuring/XWayland/#hidpi-xwayland
      xwayland.force_zero_scaling = true;

      input = {
        kb_layout = "us";

        # Enable numlock by default.
        numlock_by_default = true;

        # Disable mouse acceleration
        accel_profile = "flat";

        # Only move keyboard focus on click
        follow_mouse = 2;

        # Only focus windows when the mouse crosses a window boundary
        # NOTE: this seems to fix issues with pop-ups in JetBrains IDEs
        #
        # TODO: is this option still wanted/needed.
        mouse_refocus = false;

        # TODO: document
        resolve_binds_by_sym = true;

        touchpad = {
          # Allow using the trackpad while typing.
          #
          # TODO: see if there is a way to only allow this while a game or
          # fullscreen window is focused.
          disable_while_typing = false;

          # Enable natural scrolling when using a touchpad.
          natural_scroll = true;

          scroll_factor = 0.50;
        };
      };

      general = {
        # Border Colors
        "col.active_border" = "$surface1";
        "col.inactive_border" = "$surface0";

        # Use smaller window gaps
        gaps_in = 4;
        gaps_out = 12;

        # Allow tearing in fullscreen applications.
        # TODO: this was causing CS2 to stop rendering while fullscreened, even with an `immediate` windowrule.
        # ref; https://wiki.hypr.land/Configuring/Tearing/
        # allow_tearing = true;
      };

      cursor = {
        # Disable gsettings sync
        sync_gsettings_theme = false;

        # Disable cursor warping.
        no_warps = true;

        # Move the cursor to the last focused window when switching workspaces.
        # 2 allows this to work even if `no_warps` is enabled.
        warp_on_change_workspace = 2;

        default_monitor =
          if isDesktop
          then "DP-4"
          else "eDP-1";
      };

      # Disable animations.
      animations.enabled = false;

      decoration = {
        # Round the corners of windows
        rounding = 8;

        # Disable drop shadows
        shadow.enabled = false;

        # Disable window background blur
        blur.enabled = false;
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      misc = {
        # Ensure vfr is on.
        vfr = true;

        # Disable config auto-reloading.
        disable_autoreload = true;

        # Disable logo and splash.
        disable_hyprland_logo = true;
        disable_splash_rendering = true;

        # Disable the default wallpaper, we will load our own with hyprpaper.
        force_default_wallpaper = 0;

        # Wake monitors on key presses
        key_press_enables_dpms = true;
        mouse_move_enables_dpms = false;

        # Focus a window on `activate`
        focus_on_activate = true;
      };

      ecosystem = {
        # I follow updates myself and auto-update with Nix.
        no_update_news = true;

        # I already donate to the project :)
        no_donation_nag = true;
      };

      render = {
        # Ensure color management is enabled.
        cm_enabled = true;

        # Passthrough color settings for all fullscreen applications.
        cm_fs_passthrough = 1;

        # Use `cm, hdredid` (2) instead of `cm, hdr` (1) when using Auto HDR.
        cm_auto_hdr = 2;

        # Enable direct scanout for fullscreen game or video applications.
        direct_scanout = 2;
      };

      # Monitor configuration
      monitorv2 =
        if isDesktop
        then [
          {
            output = "DP-4";
            mode = "3840x2160@240";
            position = "0x0";
            scale = "1.5";
            # bitdepth = 8;
            # cm = "srgb";
            bitdepth = 10;
            cm = "hdredid";
            sdrbrightness = 0.96;
            sdrsaturation = 1.08;
            supports_wide_color = true;
            supports_hdr = true;
            sdr_min_luminance = 0.005;
            sdr_max_luminance = 275;
            min_luminance = 0;
            max_luminance = 1000;
            max_avg_luminance = 400;
            vrr = 3; # Enable VRR (variable refresh-rate) for fullscreened `game` or `video` windows.
          }
          {
            output = "DP-3";
            mode = "3840x2160@60";
            position = "-2560x-720";
            scale = "1.5";
            bitdepth = 8;
          }
          {
            output = "DP-2";
            mode = "3840x2160@60";
            position = "-2560x720";
            scale = "1.5";
            bitdepth = 8;
          }
        ]
        else [
          {
            output = "eDP-1";
            mode = "2560x1600@165";
            position = "0x0";
            scale = "1.333333";
            bitdepth = 8;
            vrr = 3;
          }
          {
            output = "desc:Microstep MPG321UX OLED 0x01010101";
            mode = "3840x2160@240";
            position = "auto-center-up";
            scale = "1.5";
            bitdepth = 10;
            cm = "hdredid";
            sdrbrightness = 0.98;
            sdrsaturation = 1.1;
            supports_wide_color = true;
            supports_hdr = true;
            sdr_min_luminance = 0.005;
            sdr_max_luminance = 275;
            min_luminance = 0;
            max_luminance = 1000;
            max_avg_luminance = 400;
            vrr = 3; # Enable VRR (variable refresh-rate) for fullscreened `game` or `video` windows.
          }
        ];

      workspace =
        [
          # Special workspaces that can be toggled on and off
          "special:terminal, on-created-empty:${alacritty}"
          "special:discord,  on-created-empty:${discord}"
          "special:slack,    on-created-empty:${slack}"
          "special:music,    on-created-empty:${supersonic}"
        ]
        ++ lib.optionals isDesktop [
          # Configure default workspaces for the monitors
          "1, monitor:DP-1, default:true"
          "2, monitor:DP-2, default:true"
          "3, monitor:DP-3, default:true"
        ];

      windowrule = [
        # Disable borders on floating windows.
        "match:float yes, border_size 0"

        # Inhibit idle whenever an application is fullscreened.
        # TODO: utilize window's content? (like game or video).
        "match:fullscreen 1, idle_inhibit always"

        # Picture in picture.
        "match:title Picture-in-Picture, float yes, force_rgbx yes, content video"

        # Float dialogs (mostly xdg-desktop-portal-gtk)
        "match:title ^(Accounts)(.*)$, no_screen_share yes, dim_around yes, center yes, float yes, pin yes"
        "match:title ^(Choose wallpaper)(.*)$, no_screen_share yes, dim_around yes, center yes, float yes, pin yes"
        "match:title ^(Library)(.*)$, no_screen_share yes, dim_around yes, center yes, float yes, pin yes"
        "match:title ^(Save As)(.*)$, no_screen_share yes, dim_around yes, center yes, float yes, pin yes"
        "match:title ^(Save File)(.*)$, no_screen_share yes, dim_around yes, center yes, float yes, pin yes"
        "match:title ^(Select a File)(.*)$, no_screen_share yes, dim_around yes, center yes, float yes, pin yes"
        "match:title ^(Open File)(.*)$, no_screen_share yes, dim_around yes, center yes, float yes, pin yes"
        "match:title ^(Open Folder)(.*)$, no_screen_share yes, dim_around yes, center yes, float yes, pin yes"

        # 1Password
        "match:class 1password, no_screen_share yes" # applies to both the main window and floating prompt.

        # 1Password Prompt
        "match:class 1password, match:float yes, dim_around yes, center yes, pin yes"

        # Polkit (GNOME)
        "match:class polkit-gnome-authentication-agent-1, no_screen_share yes, dim_around yes, center yes, float yes, pin yes"

        # Polkit (hyprpolkitagent)
        "match:title Hyprland Polkit Agent, no_screen_share yes, dim_around yes, center yes, float yes, pin yes"

        # Screenshare Portal
        "match:title Select what to share, no_screen_share yes, dim_around yes, center yes, float yes, pin yes"

        # GNOME Keyring Prompt
        "match:class gcr-prompter, no_screen_share yes, dim_around yes, center yes, float yes, pin yes"

        # GNOME Calculator
        "match:class org\.gnome\.Calculator, float yes"

        # Prism Launcher
        "match:title ^(.*) — Prism Launcher ([1-9]+\.[0-9])$, float yes, max_size 2880 1080"

        # Steam
        "match:title Steam, match:float yes, center yes"
        "match:class steam, match:title Steam Settings, float yes"

        "match:class steam, match:title Friends List, size 328 768, float yes"

        "match:class steam, match:title negative:^(Steam|.?)$, center yes, float yes" # match everything but "Steam" or an empty title (dropdowns)

        # mpv
        "match:class mpv, content video, fullscreen yes"

        # Wine dialogs
        "match:title (Wine), center yes, float yes, pin yes"

        # CS2
        "match:class cs2, content game, fullscreen yes, no_anim yes, no_dim yes, border_size 0, render_unfocused yes"

        # Game (Proton or Wine)
        "match:class (.*)\.exe$, content game, fullscreen yes, no_anim yes, no_dim yes, border_size 0"

        # Star Citizen
        "match:title ^RSI Launcher$, center yes, float yes, max_size 1280 720"
        "match:class ^starcitizen_launcher\.exe$, center yes, float yes, max_size 1920 1080"

        # Star Trek Online (Launcher)
        "match:class ^star trek online\.exe$, center yes, float yes, max_size 1920 1080"

        # Polychromatic
        "match:class polychromatic, match:title negative:Polychromatic, center yes, float yes, max_size 1920 1080"

        # Virt Manager
        "match:class ^\.virt-manager-wrapped$, match:title negative:Virtual Machine Manager, center yes, float yes, max_size 1920 1080"
      ];

      # Keybinds
      "$mainMod" = "Super";
      bind = [
        # Special workspace keybinds, used to toggle the workspaces on and off
        "$mainMod, C, togglespecialworkspace, terminal"
        "$mainMod, D, togglespecialworkspace, discord"
        "$mainMod, S, togglespecialworkspace, slack"
        "$mainMod, M, togglespecialworkspace, music"

        # Special workspace keybinds, used to move windows into the workspace
        "$mainMod Shift, C, movetoworkspace, special:terminal"
        "$mainMod Shift, D, movetoworkspace, special:discord"
        "$mainMod Shift, S, movetoworkspace, special:slack"
        "$mainMod Shift, M, movetoworkspace, special:music"

        # Screenshot keybinds
        ", Print, exec, ${screenshot-activeworkspace}"
        "$mainMod, Print, exec, ${screenshot-selectwindow}"
        "Shift, Print, exec, ${screenshot}"

        # Utility keybinds
        ", F11, fullscreen"
        "$mainMod, Q, killactive"

        # Application keybinds
        "$mainMod, Space, exec, ${lib.getExe outputs.packages."${pkgs.stdenv.hostPlatform.system}".ags} toggle launcher"
        "$mainMod, T, exec, ${alacritty}" # Terminal
        "$mainMod, B, exec, ${firefox}" # Web Browser
        "$mainMod, Z, exec, ${zed-editor}" # Code Editor

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

        # Move active window with arrow keys
        "$mainMod, Left, movewindow, l"
        "$mainMod, Right, movewindow, r"
        "$mainMod, Up, movewindow, u"
        "$mainMod, Down, movewindow, d"

        # hyprlock keybinds
        #
        # hyprlock is wired up via hypridle to systemd.
        #
        # `loginctl lock-session` will launch only hyprlock,
        # while `systemctl suspend` will handle both hyprlock
        # and any other actions; such as DPMS.
        "$mainMod, L, exec, ${lock}"

        # Use Tab to switch between windows in a floating workspace
        "$mainMod, Tab, cyclenext," # Change focus to another window
        "$mainMod, Tab, bringactivetotop," # Bring it to the top
      ];

      # bindl allows the bind to be used even when an input inhibitor is active
      bindl = [
        # Suspend on laptop lid close.
        ", switch:on:Lid Switch, exec, ${lib.getExe' systemd "systemctl"} suspend"

        "$mainMod Shift, L, exec, ${lib.getExe' systemd "systemctl"} suspend"

        ", XF86AudioPlay, exec, ${lib.getExe pkgs.playerctl} play-pause"
        ", XF86AudioPrev, exec, ${lib.getExe pkgs.playerctl} previous"
        ", XF86AudioNext, exec, ${lib.getExe pkgs.playerctl} next"

        # Mute audio (volume adjustment is bound under `binde`)
        ", XF86AudioMute, exec, ${lib.getExe' nixosConfig.services.pipewire.wireplumber.package "wpctl"} set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, ${lib.getExe' nixosConfig.services.pipewire.wireplumber.package "wpctl"} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ];

      bindm = [
        # $mainMod + Left-click to drag window
        "$mainMod, mouse:272, movewindow"
      ];

      # bindl allows the bind to be used even when an input inhibitor is active
      #
      # binde is for repeated inputs (trigger action multiple times while key is held)
      bindle =
        [
          # Volume up/down
          ", XF86AudioRaiseVolume, exec, ${lib.getExe' nixosConfig.services.pipewire.wireplumber.package "wpctl"} set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, ${lib.getExe' nixosConfig.services.pipewire.wireplumber.package "wpctl"} set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-"
        ]
        ++ lib.optionals (!isDesktop) [
          # Brightness
          ", XF86MonBrightnessDown, exec, ${lib.getExe pkgs.brightnessctl} --device=amdgpu_bl1 set 5%-"
          ", XF86MonBrightnessUp, exec, ${lib.getExe pkgs.brightnessctl} --device=amdgpu_bl1 set +5%"
        ];
    };
  };
}
