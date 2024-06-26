{
  flake.nixosModules.hyprland = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [
      ./greetd.nix
      ./gsettings.nix
    ];

    # Enable hyprlock PAM (and gnome-keyring integration)
    security.pam.services.hyprlock.enableGnomeKeyring = lib.mkDefault config.services.gnome.gnome-keyring.enable;

    # Enable GNOME keyring.
    #
    # This configures system components, but not a service for GNOME keyring,
    # the GNOME keyring service is configured under home-manager.
    services.gnome.gnome-keyring.enable = lib.mkDefault true;

    services.gnome.gnome-online-accounts.enable = lib.mkDefault true;
    services.gnome.evolution-data-server.enable = lib.mkDefault true;

    # Enable upower
    services.upower = {
      enable = lib.mkDefault true;
      criticalPowerAction = lib.mkDefault "PowerOff";
    };

    # Enable gvfs
    services.gvfs.enable = lib.mkDefault true;

    # Fixes issues with XDG portal definitions not being detected.
    environment.pathsToLink = ["/share/applications" "/share/xdg-desktop-portal"];

    # Add required packages to path.
    environment.systemPackages = with pkgs; [pciutils];
  };
}
