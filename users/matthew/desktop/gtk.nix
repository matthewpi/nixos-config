{
  lib,
  pkgs,
  ...
}: {
  gtk = {
    enable = true;

    cursorTheme = {
      name = "macOS-Monterey";
      package = pkgs.apple-cursor;
    };

    iconTheme = {
      name = "WhiteSur-dark";
      package = pkgs.whitesur-icon-theme;
    };

    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };

    font = {
      name = "Inter Regular";
      package = pkgs.inter;
      size = 11;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-options = "zoom";

      # TODO: package?
      picture-uri = "file:///home/matthew/Pictures/nix-magenta-blue-1920x1080.png";
      picture-uri-dark = "file:///home/matthew/Pictures/nix-black-4k.png";
    };

    "org/gnome/desktop/interface" = {
      clock-show-weekday = true;
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      font-hinting = "slight";
      font-antialiasing = "rgba";
      gtk-enable-primary-paste = false;

      document-font-name = "Inter 11";
      monospace-font-name = "Hack Nerd Font Mono 10";
    };

    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
      speed = lib.hm.gvariant.mkDouble 0.0;
    };

    "org/gnome/desktop/privacy" = {
      disable-camera = true;
      disable-microphone = true;

      remember-recent-files = true;
      recent-files-max-age = 30;

      remove-old-trash-files = true;
      remove-old-temp-files = true;
      old-files-age = 14;
    };

    "org/gnome/desktop/session" = {
      idle-delay = lib.hm.gvariant.mkUint32 600;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
      num-workspaces = 1;

      titlebar-font = "Inter 11";
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      edge-tiling = true;
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-schedule-from = 21.0;
      night-light-schedule-to = 9.0;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-timeout = 1800;
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;

      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "blur-my-shell@aunetx"
        "dash-to-panel@jderose9.github.com"
        "hide-minimized@danigm.net"
        "just-perfection-desktop@just-perfection"
        "remove-alt-tab-delay@daase.net"
        "Vitals@CoreCoding.com"
      ];

      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "firefox.desktop"
        "discord-canary.desktop"
        "spotify.desktop"
        "com.raggesilver.BlackBox.desktop"
        "codium.desktop"
        "slack.desktop"
      ];
    };

    "org/gnome/shell/extensions/dash-to-panel" = {
      appicon-margin = 4;

      dot-style-focused = "DOTS";
      dot-style-unfocused = "DOTS";
      dot-position = "TOP";

      hide-overview-on-startup = true;

      panel-sizes = "{\"0\":40,\"1\":40}";
      panel-positions = "{\"0\":\"TOP\",\"1\":\"TOP\"}";
    };

    "org/gnome/system/location" = {
      enabled = false;
    };

    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      show-hidden = true;
      sort-directories-first = true;
    };
  };

  home.packages = with pkgs; [
    gnomeExtensions.appindicator
    gnomeExtensions.blur-my-shell
    gnomeExtensions.dash-to-panel
    gnomeExtensions.hide-minimized
    gnomeExtensions.just-perfection
    gnomeExtensions.remove-alttab-delay-v2
  ];

  # Monitor settings
  xdg.configFile."monitors.xml".text = ''
    <monitors version="2">
      <configuration>
        <logicalmonitor>
          <x>0</x>
          <y>0</y>
          <scale>1</scale>
          <monitor>
            <monitorspec>
              <connector>HDMI-1</connector>
              <vendor>ACR</vendor>
              <product>GN246HL</product>
              <serial>LW3AA0018533</serial>
            </monitorspec>
            <mode>
              <width>1920</width>
              <height>1080</height>
              <rate>60.000</rate>
            </mode>
          </monitor>
        </logicalmonitor>
        <logicalmonitor>
          <x>1920</x>
          <y>0</y>
          <scale>1</scale>
          <primary>yes</primary>
          <monitor>
            <monitorspec>
              <connector>DP-3</connector>
              <vendor>VSC</vendor>
              <product>XG2405</product>
              <serial>VYE204002754</serial>
            </monitorspec>
            <mode>
              <width>1920</width>
              <height>1080</height>
              <rate>144.001</rate>
            </mode>
          </monitor>
        </logicalmonitor>
      </configuration>
    </monitors>
  '';
}
