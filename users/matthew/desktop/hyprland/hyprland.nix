{
  config,
  isDesktop,
  lib,
  nixosConfig,
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

  # Command used to launch cider.
  cider = mkSystemdRun {
    name = "sh.cider.Cider";
    command = lib.getExe pkgs.cider2;
  };

  # Command used to launch discord.
  discord = mkSystemdRun {
    name = "com.discord.Discord";
    command = lib.getExe pkgs.discord;
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
    systemd.enable = !nixosConfig.programs.uwsm.enable;

    settings = {
      # Enable the experimental color management protocol.
      experimental.xx_color_management_v4 = true;

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
          then "DP-1"
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

        # Enable VRR (variable refresh-rate) for fullscreened `game` or `video`
        # windows.
        vrr = 3;

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

      ecosystem.no_update_news = true;

      render = {
        # Disable direct scanout as it causes artifacting in fullscreen games.
        direct_scanout = 0;

        # Passthrough color settings for all fullscreen applications.
        cm_fs_passthrough = 1;

        # Ensure color management is enabled.
        cm_enabled = true;
      };

      # Monitor configuration
      monitor =
        if isDesktop
        then [
          # "DP-1, 3840x2160@240, 0x0, 1.5, bitdepth,10, cm,hdr, sdrbrightness,1.36, sdrsaturation,0.98" # or cm,wide
          # "DP-1, 3840x2160@240, 0x0, 1.5, bitdepth,10, cm,auto"
          "DP-1, 3840x2160@240, 0x0, 1.5, bitdepth,8, cm,srgb"
          "DP-2, 3840x2160@60, -2560x-720, 1.5, bitdepth,8, cm,srgb"
          "DP-3, 3840x2160@60, -2560x720, 1.5, bitdepth,8, cm,srgb"
        ]
        else [
          "eDP-1, 2560x1600@165, 0x0, 1.333333, vrr,0, bitdepth,8"
          # ", preferred, auto, 1, vrr,0, bitdepth,8"
        ];

      workspace =
        [
          # Special workspaces that can be toggled on and off
          "special:terminal, on-created-empty:${alacritty}"
          "special:discord,  on-created-empty:${discord}"
          "special:slack,    on-created-empty:${slack}"
          "special:music,    on-created-empty:${cider}"
        ]
        ++ lib.optionals isDesktop [
          # Configure default workspaces for the monitors
          "1, monitor:DP-1, default:true"
          "2, monitor:DP-2, default:true"
          "3, monitor:DP-3, default:true"
        ];

      windowrule = [
        # Disable borders on floating windows.
        "noborder, floating:1"

        # Inhibit idle whenever an application is fullscreened.
        # TODO: utilize window's content? (like game or video).
        "idleinhibit always, fullscreen:1"

        # Picture in picture
        "float,         title:Picture-in-Picture"
        "forcergbx,     title:Picture-in-Picture"
        "content video, title:Picture-in-Picture"

        # Float dialogs (mostly xdg-desktop-portal-gtk)
        "float, title:^(Accounts)(.*)$"
        "float, title:^(Choose wallpaper)(.*)$"
        "float, title:^(Library)(.*)$"
        "float, title:^(Save As)(.*)$"
        "float, title:^(Save File)(.*)$"
        "float, title:^(Select a File)(.*)$"
        "float, title:^(Open File)(.*)$"
        "float, title:^(Open Folder)(.*)$"

        # Polkit (GNOME)
        "dimaround, class:polkit-gnome-authentication-agent-1"
        "center,    class:polkit-gnome-authentication-agent-1"
        "float,     class:polkit-gnome-authentication-agent-1"
        "pin,       class:polkit-gnome-authentication-agent-1"

        # Polkit (hyprpolkitagent)
        "dimaround, title:Hyprland Polkit Agent"
        "center,    title:Hyprland Polkit Agent"
        "float,     title:Hyprland Polkit Agent"
        "pin,       title:Hyprland Polkit Agent"

        # Screenshare Portal
        "dimaround, title:MainPicker"
        "center,    title:MainPicker"
        "float,     title:MainPicker"
        "pin,       title:MainPicker"

        # GNOME Keyring Prompt
        "dimaround, class:gcr-prompter"
        "center,    class:gcr-prompter"
        "float,     class:gcr-prompter"
        "pin,       class:gcr-prompter"

        # GNOME Calculator
        "float, class:org\.gnome\.Calculator"

        # 1Password Prompt
        "dimaround, class:1Password, floating:1"
        "center,    class:1Password, floating:1"
        "pin,       class:1Password, floating:1"

        # Prism Launcher
        "float, title:^(.*) — Prism Launcher ([1-9]+\.[0-9])$"
        "size <75% 50%, title:^(.*) — Prism Launcher ([1-9]+\.[0-9])$"

        # Steam
        "center, title:Steam, floating:1"
        "float,  title:Steam Settings, class:steam"
        "float,  title:Friends List, class:steam"
        "center, class:^(steam)$, title:negative:^Steam$"
        "float,  class:^(steam)$, title:negative:^Steam$"

        # mpv
        "content video, class:mpv"
        "fullscreen,    class:mpv"

        # Wine dialogs
        "center, title:(Wine)"
        "float,  title:(Wine)"
        "pin,    title:(Wine)"

        # Game (Proton or Wine)
        "content game, class:(.*)\.exe$"
        "noanim,       class:(.*)\.exe$"
        "noborder,     class:(.*)\.exe$"
        "nodim,        class:(.*)\.exe$"

        # Star Citizen
        "size <50% <50%, class:^rsi launcher\.exe$"
        "center,         class:^rsi launcher\.exe$"
        "float,          class:^rsi launcher\.exe$"
        "size <50% <50%, class:^starcitizen_launcher\.exe$"
        "center,         class:^starcitizen_launcher\.exe$"
        "float,          class:^starcitizen_launcher\.exe$"
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
        # "$mainMod Shift, Space, exec, ${lib.getExe pkgs.gauntlet} open"
        "$mainMod, Space, exec, ${lib.getExe' config.programs.ags.package "ags"} toggle launcher"
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
        # "$mainMod, Tab, cyclenext," # Change focus to another window
        # "$mainMod, Tab, bringactivetotop," # Bring it to the top
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
        ", XF86AudioMute, exec, ${lib.getExe' config.services.avizo.package "volumectl"} toggle-mute" # wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ", XF86AudioMicMute, exec, ${lib.getExe' config.services.avizo.package "volumectl"} -m toggle-mute"
      ];

      bindm = [
        # $mainMod + Left-click to drag window
        "$mainMod, mouse:272, movewindow"
      ];

      # bindl allows the bind to be used even when an input inhibitor is active
      #
      # binde is for repeated inputs (trigger action multiple times while key is held)
      bindle = [
        # Volume up/down
        ", XF86AudioRaiseVolume, exec, ${lib.getExe' config.services.avizo.package "volumectl"} -u up" # wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
        ", XF86AudioLowerVolume, exec, ${lib.getExe' config.services.avizo.package "volumectl"} -u down" # wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-

        # Brightness
        ", XF86MonBrightnessDown, exec, ${lib.getExe' config.services.avizo.package "lightctl"} down" # brightnessctl --device=amdgpu_bl1 set 5%-
        ", XF86MonBrightnessUp, exec, ${lib.getExe' config.services.avizo.package "lightctl"} up" # brightnessctl --device=amdgpu_bl1 set +5%
      ];
    };
  };

  services.avizo = {
    enable = true;
    settings.default = {
      time = 1.0;
      width = 192;
      height = 192;
      padding = 16;
      y-offset = 0.75;
      x-offset = 0.5;
      border-radius = 16;
      border-width = 1;
      block-height = 10;
      block-spacing = 2;
      block-count = 20;
      fade-in = 0.1;
      fade-out = 0.2;
      background = "rgba(49, 50, 68, 0.75)"; # Surface 0
      border-color = "rgba(69, 71, 90, 1.0)"; # Surface 1
      bar-bg-color = "rgba(88, 91, 112, 1.0)"; # Surface 2
      bar-fg-color = "rgba(203, 166, 247, 1.0)"; # Mauve
    };
  };
  systemd.user.services.avizo.Service.Slice = "background.slice";
}
