{
  flake.nixosModules.hyprland = {
    config,
    inputs,
    lib,
    pkgs,
    ...
  }: {
    imports = [
      ./greetd.nix
      ./gsettings.nix

      inputs.catppuccin.nixosModules.catppuccin
    ];

    catppuccin.tty.enable = true;

    # TODO: not reference home-manager for the package.
    programs.hyprland.package = config.home-manager.users.matthew.wayland.windowManager.hyprland.finalPackage;

    # Add required packages to path.
    environment.systemPackages = [config.programs.hyprland.package pkgs.pciutils];

    # Install hyprland as a session package so it can be used by tuigreet.
    services.displayManager.sessionPackages = [config.programs.hyprland.package];

    # Path fixes for Hyprland.
    systemd.user.extraConfig = ''
      DefaultEnvironment="PATH=/run/wrappers/bin:/nix/profile/bin:/etc/profiles/per-user/%u/bin:/run/current-system/sw/bin:$PATH"
    '';

    # Configure hyprlock PAM.
    security.pam.services.hyprlock = {
      # Enable gnome-keyring integration if enabled.
      enableGnomeKeyring = lib.mkDefault config.services.gnome.gnome-keyring.enable;

      # Disable fprint auth since hyprlock supports accessing fprintd using DBUS.
      fprintAuth = false;
    };

    # Enable GNOME keyring.
    #
    # This configures system components, but not a service for GNOME keyring,
    # the GNOME keyring service is configured under home-manager.
    services.gnome.gnome-keyring.enable = lib.mkDefault true;

    # Enable upower for power management.
    services.upower = {
      enable = lib.mkDefault true;
      criticalPowerAction = lib.mkDefault "PowerOff";
    };

    # Enable gvfs
    services.gvfs.enable = lib.mkDefault true;

    # Fixes issues with XDG portal definitions not being detected.
    # ref; https://nix-community.github.io/home-manager/options.xhtml#opt-xdg.portal.enable
    environment.pathsToLink = ["/share/applications" "/share/xdg-desktop-portal"];
  };
}
