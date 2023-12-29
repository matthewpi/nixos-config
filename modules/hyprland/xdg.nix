{
  lib,
  pkgs,
  ...
}: {
  # Enable xdg-desktop-portal.
  xdg.portal = {
    enable = lib.mkDefault true;
    xdgOpenUsePortal = lib.mkForce false;
    extraPortals = with pkgs; [xdg-desktop-portal-gtk];
  };

  # Add additional settings to the default xdg-desktop-portal-gtk user service.
  systemd.user.services.xdg-desktop-portal-gtk = {
    partOf = ["graphical-session.target"];
    after = ["graphical-session.target"];
    unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
    serviceConfig = {
      Restart = "on-failure";
      Slice = "session.slice";
    };
  };

  # Add xdg-utils to our packages.
  environment.systemPackages = with pkgs; [xdg-utils];
}
