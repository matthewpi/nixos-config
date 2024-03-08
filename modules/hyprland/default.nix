{
  flake.nixosModules.hyprland = {
    config,
    lib,
    ...
  }: {
    imports = [
      ./greetd.nix
    ];

    # Enable hyprlock PAM (and gnome-keyring integration)
    #
    # Won't do anything until https://github.com/hyprwm/hyprlock/issues/4#issuecomment-1960904526 is resolved.
    security.pam.services.hyprlock.enableGnomeKeyring = lib.mkDefault config.services.gnome.gnome-keyring.enable;

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
