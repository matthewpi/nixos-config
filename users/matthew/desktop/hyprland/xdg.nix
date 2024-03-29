{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [glib xdg-utils];

  xdg.portal = {
    enable = lib.mkDefault true;
    xdgOpenUsePortal = lib.mkDefault false;
    extraPortals = [
      (pkgs.xdg-desktop-portal-hyprland.override {
        hyprland = config.wayland.windowManager.hyprland.finalPackage;
      })
      pkgs.xdg-desktop-portal-gtk
    ];
    configPackages = [
      config.wayland.windowManager.hyprland.finalPackage
    ];

    config.hyprland.default = ["hyprland" "gtk"];
  };

  # TODO: fix override, this doesn't work as the systemd configuration for the gtk portal is linked from it's package.
  # Add additional settings to the default xdg-desktop-portal-gtk user service.
  #systemd.user.services.xdg-desktop-portal-gtk = {
  #  Unit = {
  #    PartOf = ["hyprland-session.target"];
  #    After = ["hyprland-session.target"];
  #    ConditionEnvironment = "WAYLAND_DISPLAY";
  #  };
  #  Service = {
  #    Restart = "on-failure";
  #    Slice = "session.slice";
  #  };
  #};

  xdg.userDirs = {
    enable = true;
    # createDirectories = true;
  };
}
