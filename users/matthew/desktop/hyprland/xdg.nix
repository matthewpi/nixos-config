{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs) xdg-desktop-portal-gtk;
  xdg-desktop-portal-hyprland = pkgs.xdg-desktop-portal-hyprland.override {
    hyprland = config.wayland.windowManager.hyprland.finalPackage;
  };
in {
  # grim and slurp are wanted by XDPH.
  home.packages = with pkgs; [glib xdg-utils grim slurp];

  xdg.portal = {
    enable = lib.mkDefault true;
    xdgOpenUsePortal = lib.mkDefault true;
    extraPortals = [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config.hyprland.default = ["hyprland" "gtk"];
  };

  systemd.user.services = {
    xdg-desktop-portal = {
      Unit = {
        Description = "Portal service";
        PartOf = ["hyprland-session.target"];
        After = ["hyprland-session.target"];
      };
      Service = {
        Slice = "session.slice";
        Type = "dbus";
        BusName = "org.freedesktop.portal.Desktop";
        ExecStart = "${pkgs.xdg-desktop-portal}/libexec/xdg-desktop-portal";
        Restart = "on-failure";
      };
    };

    xdg-desktop-portal-gtk = {
      Unit = {
        Description = "Portal service (GTK/GNOME implementation)";
        PartOf = ["hyprland-session.target"];
        After = ["hyprland-session.target"];
      };
      Service = {
        Slice = "session.slice";
        Type = "dbus";
        BusName = "org.freedesktop.impl.portal.desktop.gtk";
        ExecStart = "${xdg-desktop-portal-gtk}/libexec/xdg-desktop-portal-gtk";
        Restart = "on-failure";
      };
    };

    xdg-desktop-portal-hyprland = {
      Unit = {
        Description = "Portal service (Hyprland implementation)";
        PartOf = ["hyprland-session.target"];
        After = ["hyprland-session.target"];
      };
      Service = {
        Slice = "session.slice";
        Type = "dbus";
        BusName = "org.freedesktop.impl.portal.desktop.hyprland";
        ExecStart = "${xdg-desktop-portal-hyprland}/libexec/xdg-desktop-portal-hyprland";
        Restart = "on-failure";
      };
    };
  };

  xdg.userDirs = {
    enable = true;
    # createDirectories = true;
  };
}
