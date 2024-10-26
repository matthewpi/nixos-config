{
  config,
  lib,
  pkgs,
  ...
}: {
  home.sessionVariables = {
    # Use gsettings to check for dark mode
    # https://gitlab.gnome.org/GNOME/libadwaita/-/commit/e715fae6a509db006a805af816f9d163f81011ef
    ADW_DISABLE_PORTAL = "1";
  };

  gtk = {
    enable = true;
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk3.bookmarks = [
      "file:///code"
      "file://${config.home.homeDirectory}/Documents"
      "file://${config.home.homeDirectory}/Downloads"
      "file://${config.home.homeDirectory}/Music"
      "file://${config.home.homeDirectory}/Pictures"
      "file://${config.home.homeDirectory}/Videos"
    ];

    iconTheme = {
      name = "WhiteSur-dark";
      package = pkgs.whitesur-icon-theme;
    };

    # TODO: only apply the gtk3 adwaita theme to gtk3 apps, gtk4 should not be affected by it.
    theme.name = "Adwaita";

    font = {
      name = "Inter Regular";
      package = pkgs.inter;
      size = 11;
    };
  };

  # Disable any gtk-4.0 specific styling, I don't want to theme libadwaita.
  xdg.configFile."gtk-4.0/gtk.css".enable = false;

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

    "org/gnome/desktop/interface" = {
      clock-show-weekday = true;
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      font-hinting = "slight";
      font-antialiasing = "rgba";
      gtk-enable-primary-paste = false;

      document-font-name = "Inter 11";
      monospace-font-name = "MonaspiceNe Nerd Font 10";
    };

    "org/gnome/desktop/privacy" = {
      #disable-camera = true;
      #disable-microphone = true;

      remember-recent-files = true;
      recent-files-max-age = 30;

      remove-old-trash-files = true;
      remove-old-temp-files = true;
      old-files-age = 14;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:close";

      titlebar-font = "Inter 11";
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
    };

    "org/gtk/settings/file-chooser" = {
      sort-directories-first = true;
      show-hidden = true;
    };

    # TODO: are the `gtk4` settings necessary?
    # These may be used by GNOME, but since I switched to Hyprland,
    # they may not be necessary.
    "org/gtk/gtk4/settings/file-chooser" = {
      sort-directories-first = true;
      show-hidden = true;
    };
  };
}
