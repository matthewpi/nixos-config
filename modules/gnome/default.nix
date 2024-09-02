{
  flake.nixosModules.gnome = {
    lib,
    pkgs,
    ...
  }: {
    # Enable GNOME, GDM, and Wayland
    services.xserver = {
      enable = lib.mkDefault true;

      desktopManager.gnome.enable = lib.mkDefault true;

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
    environment.gnome.excludePackages = with pkgs; [
      cheese
      epiphany
      gedit
      gnome-characters
      gnome-console
      gnome-photos
      gnome-tour
      gnome-contacts
      gnome-initial-setup
      yelp
    ];

    # Enable xdg-desktop-portal
    xdg.portal = {
      enable = lib.mkDefault true;
      xdgOpenUsePortal = lib.mkDefault true;
    };

    # Enable wayland environment variables for Electron Ozone, SDL2, and QT
    environment.sessionVariables = {
      NIXOS_OZONE_WL = lib.mkDefault "1";
      SDL_VIDEODRIVER = lib.mkDefault "wayland";
      QT_QPA_PLATFORM = lib.mkDefault "wayland";
    };
  };
}
