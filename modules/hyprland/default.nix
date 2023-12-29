{
  flake.nixosModules.hyprland = {
    config,
    inputs,
    lib,
    pkgs,
    ...
  }: {
    imports = [
      ./dconf.nix
      ./fonts.nix
      ./greetd.nix
      ./xdg.nix
    ];

    # Enable hyprland
    programs.hyprland = {
      enable = lib.mkDefault true;
      package = lib.mkDefault inputs.hyprland.packages.${pkgs.system}.hyprland;
    };

    # Enable wayland environment variables for Electron Ozone, SDL2, and QT
    environment.sessionVariables = {
      NIXOS_OZONE_WL = lib.mkDefault "1";
      SDL_VIDEODRIVER = lib.mkDefault "wayland";
      QT_QPA_PLATFORM = lib.mkDefault "wayland";
    };

    # Enable swaylock PAM (and gnome-keyring integration)
    security.pam.services.swaylock.enableGnomeKeyring = lib.mkDefault config.services.gnome.gnome-keyring.enable;

    # Enable GNOME keyring.
    #
    # This configures system components, but not a service for GNOME keyring,
    # the GNOME keyring service is configured under home-manager.
    services.gnome.gnome-keyring.enable = lib.mkDefault true;

    # Enable upower
    services.upower = {
      enable = lib.mkDefault true;
      criticalPowerAction = lib.mkDefault "PowerOff";
    };

    # Enable gvfs
    services.gvfs.enable = lib.mkDefault true;
  };
}
