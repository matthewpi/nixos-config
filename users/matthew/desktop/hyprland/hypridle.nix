{
  config,
  lib,
  ...
}: {
  # https://wiki.hyprland.org/Hypr-Ecosystem/hypridle/
  services.hypridle = {
    enable = true;

    listeners = [
      {
        timeout = 300;
        onTimeout = lib.getExe config.programs.hyprlock.package;
        onResume = "";
      }
    ];

    lockCmd = lib.getExe config.programs.hyprlock.package;
    beforeSleepCmd = lib.getExe config.programs.hyprlock.package;
    unlockCmd = "";
    afterSleepCmd = "";
  };

  # Run hypridle under session.slice
  systemd.user.services.hypridle.Service.Slice = "session.slice";
  systemd.user.services.hypridle.Install.WantedBy = ["hyprland-session.target"];
}
