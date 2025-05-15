{
  config,
  inputs,
  lib,
  nixosConfig,
  pkgs,
  ...
}: let
  inherit (pkgs) xdg-desktop-portal-gtk;
  xdg-desktop-portal-hyprland = nixosConfig.programs.hyprland.portalPackage;
in {
  # grim and slurp are wanted by XDPH.
  home.packages = with pkgs; [glib grim slurp xdg-utils];

  xdg.portal = {
    enable = lib.mkForce true;
    xdgOpenUsePortal = true;
    extraPortals = [xdg-desktop-portal-gtk xdg-desktop-portal-hyprland];
    configPackages = [nixosConfig.programs.hyprland.package];
    config.hyprland.default = ["hyprland" "gtk"];
  };

  systemd.user.services = {
    xdg-desktop-portal = {
      Unit = {
        Description = "Portal service";
        PartOf = [config.wayland.systemd.target];
        After = [config.wayland.systemd.target];
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
        PartOf = [config.wayland.systemd.target];
        After = [config.wayland.systemd.target];
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
        PartOf = [config.wayland.systemd.target];
        After = [config.wayland.systemd.target];
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

  xdg.configFile."hypr/xdph.conf".text = inputs.home-manager.lib.hm.generators.toHyprconf {
    attrs.screencopy = {
      max_fps = 60;
      allow_token_by_default = true;
    };
  };
}
