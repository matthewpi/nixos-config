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

    # Enable hyprlock PAM (and gnome-keyring integration)
    security.pam.services.hyprlock.enableGnomeKeyring = lib.mkDefault config.services.gnome.gnome-keyring.enable;

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

    systemd.services."sleep@" = {
      restartIfChanged = false;
      description = "Call user sleep target";
      after = ["sleep.target"];
      wantedBy = ["sleep.target"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "systemctl --user --machine=%i@ start --wait sleep.target";
      };
    };

    systemd.user.targets.sleep = {
      description = "Sleep";
      documentation = ["man:systemd.special(7)"];
      unitConfig = {
        DefaultDependencies = "no";
        StopWhenUnneeded = "yes";
      };
    };

    # TODO: move this to a per-user configuration.
    systemd.targets.multi-user.wants = ["sleep@matthew.service"];
  };
}
