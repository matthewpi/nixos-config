{
  config,
  lib,
  ...
}: {
  # https://wiki.hyprland.org/Hypr-Ecosystem/hypridle/
  services.hypridle = let
    hyprlockExe = lib.getExe config.programs.hyprlock.package;
  in {
    enable = true;
    settings = {
      general = {
        lock_cmd = "${hyprlockExe} --immediate";
        before_sleep_cmd = "${hyprlockExe} --immediate";
        ignore_dbus_inhibit = false;
      };

      listener = [
        {
          # Set the timeout to 5 minutes (minus whatever the hyprlock grace-period is)
          timeout = 300 - config.programs.hyprlock.settings.general.grace;
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
