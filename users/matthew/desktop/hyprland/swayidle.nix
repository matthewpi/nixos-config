{
  config,
  lib,
  pkgs,
  ...
}: {
  # Enable swayidle.
  services.swayidle = let
    hyprland = config.wayland.windowManager.hyprland.package;
    # dimCommand blocks until `-d` number of seconds has passed, while dimming the display to black
    # over the same time period. If movement is detected in this period, the command will exit early
    # with an exit-code of 2.
    dimDuration = 10;
    dimCommand = "${lib.getExe pkgs.chayang} -d ${toString dimDuration}";
    lockCommand = "${lib.getExe config.programs.swaylock.package} --daemonize --show-failed-attempts --color 000000";
    lockWithDpms = "${lockCommand} && ${pkgs.coreutils}/bin/sleep 1s && ${hyprland}/bin/hyprctl dispatch dpms off";
  in {
    enable = true;
    systemdTarget = "hyprland-session.target";
    events = [
      {
        event = "before-sleep";
        command = lockCommand;
      }
      {
        event = "lock";
        command = lockWithDpms;
      }
      {
        event = "after-resume";
        command = "${hyprland}/bin/hyprctl dispatch dpms on";
      }
    ];
    timeouts = [
      # After 5 minutes of inactivity, lock the system.
      {
        timeout = 300 - dimDuration;
        command = "${dimCommand} && ${lockWithDpms}";
      }
      # After 15 minutes of inactivity, suspend the system.
      #{
      #  timeout = 900;
      #  command = "${pkgs.systemd}/bin/systemctl suspend";
      #}
    ];
  };

  # Run swayidle under session.slice
  systemd.user.services.swayidle.Service.Slice = "session.slice";
}
