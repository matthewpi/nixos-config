{
  config,
  lib,
  pkgs,
  ...
}: {
  # https://wiki.hyprland.org/Hypr-Ecosystem/hypridle/
  services.hypridle = let
    hyprlockExe = lib.getExe config.programs.hyprlock.package;
  in {
    enable = true;
    package = pkgs.hypridle;
    settings = {
      general = {
        lock_cmd = hyprlockExe;
        before_sleep_cmd = hyprlockExe;
        ignore_dbus_inhibit = false;
      };

      listener = [
        {
          timeout = 300;
          on-timeout = hyprlockExe;
        }
      ];
    };
  };

  systemd.user.services.hypridle = {
    Service.Slice = "session.slice";
    Unit.After = lib.mkForce [];
    Unit.PartOf = lib.mkForce ["hyprland-session.target"];
    Install.WantedBy = lib.mkForce ["hyprland-session.target"];
  };
}
