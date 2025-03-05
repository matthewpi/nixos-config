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

    # Enable Catppuccin colors on the TTY.
    catppuccin.tty.enable = true;

    # HDR
    hardware.graphics.extraPackages = [pkgs.vulkan-hdr-layer];

    # Disable XWayland since we don't need it for any applications.
    programs.xwayland.enable = false;

    # Configure Hyprland and it's package.
    programs.hyprland = {
      # NOTE: this is intentional, if we enable this a bunch of settings get
      # configured at the NixOS level, some of which we don't want (XDG portals).
      #
      # Most of our configuration is done at the home-manager level, so we only
      # want the basic essentials in the NixOS config.
      enable = false;
      package = pkgs.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
      xwayland.enable = config.programs.xwayland.enable;
      withUWSM = true;
    };

    # Configure UWSM.
    programs.uwsm = {
      enable = true;
      waylandCompositors.hyprland = {
        prettyName = "Hyprland";
        comment = "Hyprland compositor managed by UWSM";
        binPath = "/run/current-system/sw/bin/Hyprland";
      };
    };

    # Add required packages to path.
    environment.systemPackages = [config.programs.hyprland.package pkgs.pciutils];

    # Path fixes for Hyprland.
    systemd.user.extraConfig = ''
      DefaultEnvironment="PATH=/run/wrappers/bin:/nix/profile/bin:/etc/profiles/per-user/%u/bin:/run/current-system/sw/bin:$PATH"
    '';

    # Configure hyprlock PAM.
    security.pam.services.hyprlock = {
      # Enable gnome-keyring integration only if gnome-keyring is enabled.
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

    # Enable glib-networking.
    services.gnome.glib-networking.enable = lib.mkDefault true;

    # Fixes issues with XDG portal definitions not being detected.
    # ref; https://nix-community.github.io/home-manager/options.xhtml#opt-xdg.portal.enable
    environment.pathsToLink = ["/share/applications" "/share/xdg-desktop-portal"];
  };
}
