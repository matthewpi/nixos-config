{
  flake.nixosModules.gnome = {
    lib,
    pkgs,
    ...
  }: {
    # Set fonts
    fonts = {
      fontconfig = {
        defaultFonts = {
          serif = lib.mkDefault ["DejaVu Serif"];
          sansSerif = lib.mkDefault ["DejaVu Sans"];
          monospace = lib.mkDefault ["DejaVu Sans Mono"];
          emoji = lib.mkDefault ["Noto Color Emoji"];
        };
      };

      fontDir.enable = true;

      packages = with pkgs; [
        inter
        hack-font
        monaspace
        (nerdfonts.override {
          fonts = ["Hack" "Monaspace"];
        })
      ];
    };

    # Enable GNOME, GDM, and Wayland
    services.xserver = {
      enable = lib.mkDefault true;

      desktopManager.gnome = {
        enable = lib.mkDefault true;

        # GNOME Realtime
        # ref; https://github.com/NixOS/nixpkgs/issues/219926
        # extraGSettingsOverridesPackages = [pkgs.gnome.mutter];
        # extraGSettingsOverrides = ''
        #   [org.gnome.mutter]
        #   experimental-features=['rt-scheduler']
        # '';
      };

      displayManager.gdm = {
        autoSuspend = lib.mkDefault false;
        enable = lib.mkDefault true;
        wayland = lib.mkDefault true;
      };

      layout = lib.mkDefault "us";

      libinput = {
        enable = lib.mkDefault true;

        mouse = {
          accelProfile = lib.mkDefault "flat";
          middleEmulation = lib.mkDefault false;
        };

        touchpad = {
          accelProfile = lib.mkDefault "flat"; # TODO: figure out what the best setting is if I am using a laptop
          disableWhileTyping = lib.mkDefault true;
          middleEmulation = lib.mkDefault true;
          naturalScrolling = lib.mkDefault true;
        };
      };
    };

    # Yeet packages that I don't want
    environment.gnome.excludePackages =
      (with pkgs; [
        gnome-console
        gnome-photos
        gnome-tour
      ])
      ++ (with pkgs.gnome; [
        cheese
        gedit
        epiphany
        gnome-characters
        yelp
        gnome-contacts
        gnome-initial-setup
      ]);

    # Enable xdg-desktop-portal
    xdg.portal = {
      enable = lib.mkDefault true;
      xdgOpenUsePortal = lib.mkDefault true;
    };

    # Enable dconf
    programs.dconf.enable = lib.mkDefault true;

    # Enable wayland environment variables for Electron Ozone, SDL2, and QT
    environment.sessionVariables = {
      NIXOS_OZONE_WL = lib.mkDefault "1";
      SDL_VIDEODRIVER = lib.mkDefault "wayland";
      QT_QPA_PLATFORM = lib.mkDefault "wayland";
    };
  };
}
