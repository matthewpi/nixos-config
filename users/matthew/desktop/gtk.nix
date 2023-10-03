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

  dconf.settings = let
    geolocationTupleType = lib.hm.gvariant.type.tupleOf [lib.hm.gvariant.type.double lib.hm.gvariant.type.double];

    mkPrimitive = t: v: {
      _type = "gvariant";
      type = t;
      value = v;
      __toString = self: "@${self.type} ${toString self.value}";
    };

    mkGeolocationTuple = elems:
      mkPrimitive geolocationTupleType elems
      // {
        __toString = self: "@${self.type} (${lib.concatMapStringsSep "," toString self.value})";
      };

    mkGeolocation = {
      somenumber ? 2,
      name,
      code,
      somebool ? true,
      coordinateX1 ? null,
      coordinateX2 ? null,
      coordinateY1 ? null,
      coordinateY2 ? null,
    }:
      lib.hm.gvariant.mkVariant (lib.hm.gvariant.mkTuple [
        (lib.hm.gvariant.mkUint32 somenumber)
        (lib.hm.gvariant.mkVariant (lib.hm.gvariant.mkTuple [
          name
          code
          (lib.hm.gvariant.mkBoolean somebool)
          (
            if (coordinateX1 != null && coordinateX2 != null)
            then
              (lib.hm.gvariant.mkArray geolocationTupleType [
                (mkGeolocationTuple [
                  (lib.hm.gvariant.mkDouble coordinateX1)
                  (lib.hm.gvariant.mkDouble coordinateX2)
                ])
              ])
            else (lib.hm.gvariant.mkEmptyArray geolocationTupleType)
          )
          (
            if (coordinateY1 != null && coordinateY2 != null)
            then
              (lib.hm.gvariant.mkArray geolocationTupleType [
                (mkGeolocationTuple [
                  (lib.hm.gvariant.mkDouble coordinateY1)
                  (lib.hm.gvariant.mkDouble coordinateY2)
                ])
              ])
            else (lib.hm.gvariant.mkEmptyArray geolocationTupleType)
          )
        ]))
      ]);

    calgary = mkGeolocation {
      name = "Calgary";
      code = "CYYC";
      coordinateX1 = 0.89215414179553232;
      coordinateX2 = -1.9899662412999655;
      coordinateY1 = 0.89157235374267252;
      coordinateY2 = -1.9911297824991001;
    };

    honolulu = mkGeolocation {
      name = "Honolulu";
      code = "PHNL";
      coordinateX1 = 0.37223509621909062;
      coordinateX2 = -2.7566263578617853;
      coordinateY1 = 0.37187632633805073;
      coordinateY2 = -2.7551476625596174;
    };

    vancouver = mkGeolocation {
      name = "Vancouver";
      code = "CYVR";
      coordinateX1 = 0.85841109795478021;
      coordinateX2 = -2.1496638678574467;
      coordinateY1 = 0.85957465660720722;
      coordinateY2 = -2.1490820798045869;
    };

    ottawa = mkGeolocation {
      name = "Ottawa";
      code = "CYOW";
      coordinateX1 = 0.79092504517986117;
      coordinateX2 = -1.3206324731601402;
      coordinateY1 = 0.7926703744318554;
      coordinateY2 = -1.3212142437597076;
    };

    utc = mkGeolocation {
      name = "Coordinated Universal Time (UTC)";
      code = "@UTC";
      somebool = false;
    };

    sydney = mkGeolocation {
      name = "Sydney";
      code = "YSSY";
      coordinateX1 = -0.59253928105207498;
      coordinateX2 = 2.6386469349889961;
      coordinateY1 = -0.59137572239964786;
      coordinateY2 = 2.6392287230418559;
    };
  in {
    "dev/deedles/Trayscale" = {
      tray-icon = false;
    };

    "org/gnome/Weather" = {
      locations = lib.hm.gvariant.mkArray lib.hm.gvariant.type.variant [calgary];
    };

    "org/gnome/clocks" = let
      locationType = lib.hm.gvariant.type.dictionaryEntryOf [lib.hm.gvariant.type.string lib.hm.gvariant.type.variant];
    in {
      world-clocks = lib.hm.gvariant.mkArray (lib.hm.gvariant.type.arrayOf locationType) [
        (lib.hm.gvariant.mkArray locationType [
          (lib.hm.gvariant.mkDictionaryEntry ["location" honolulu])
          (lib.hm.gvariant.mkDictionaryEntry ["location" vancouver])
          (lib.hm.gvariant.mkDictionaryEntry ["location" calgary])
          (lib.hm.gvariant.mkDictionaryEntry ["location" ottawa])
          (lib.hm.gvariant.mkDictionaryEntry ["location" utc])
          (lib.hm.gvariant.mkDictionaryEntry ["location" sydney])
        ])
      ];
    };

    "org/gnome/shell/weather" = {
      automatic-location = true;
      locations = lib.hm.gvariant.mkArray lib.hm.gvariant.type.variant [calgary];
    };

    "org/gnome/shell/world-clocks" = {
      locations = lib.hm.gvariant.mkArray lib.hm.gvariant.type.variant [
        honolulu
        vancouver
        calgary
        ottawa
        utc
        sydney
      ];
    };

    "org/gnome/desktop/background" = {
      picture-options = "zoom";

      # TODO: package?
      picture-uri = "file://${pkgs.catppuccin-wallpapers}/nix-magenta-blue-1920x1080.png";
      picture-uri-dark = "file://${pkgs.catppuccin-wallpapers}/nix-black-4k.png";
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
      # sleep-inactive-ac-type = "nothing";
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;

      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "blur-my-shell@aunetx"
        "dash-to-panel@jderose9.github.com"
        "hide-minimized@danigm.net"
        "just-perfection-desktop@just-perfection"
        "tailscale-status@maxgallup.github.com"
      ];

      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "firefox.desktop"
        "discord-canary.desktop"
        "com.raggesilver.BlackBox.desktop"
        "codium.desktop"
        "slack.desktop"
        "signal-desktop.desktop"
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

  home.packages = with pkgs.gnomeExtensions; [
    appindicator
    blur-my-shell
    dash-to-panel
    hide-minimized
    just-perfection
    tailscale-status
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
