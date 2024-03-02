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

    listeners = [
      {
        timeout = 300;
        onTimeout = hyprlockExe;
        onResume = "";
      }
    ];

    lockCmd = "${hyprlockExe} & sleep 3 && hyprctl dispatch dpms off";
    beforeSleepCmd = hyprlockExe;
    unlockCmd = "";
    afterSleepCmd = "";
  };

  # Run hypridle under session.slice
  systemd.user.services.hypridle.Service.Slice = "session.slice";
  systemd.user.services.hypridle.Install.WantedBy = ["hyprland-session.target"];
}
