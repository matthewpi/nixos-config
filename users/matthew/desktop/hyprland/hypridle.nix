{
  config,
  lib,
  ...
}: {
  # https://wiki.hyprland.org/Hypr-Ecosystem/hypridle/
  services.hypridle = let
    hyprlockExe = "pidof hyprlock || hyprlock";

    lockTimeout = 300;
    # dpms timeout is stacked on top of lock timeout.
    dpmsTimeout = 30;
  in {
    enable = true;
    settings = {
      general = rec {
        lock_cmd = "${hyprlockExe} --immediate";
        before_sleep_cmd = lock_cmd;
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
      };

      listener = [
        {
          # Remove the grace period from hyprlock so we can have a visual
          # indicator that the system is about to be locked. If movement is
          # detected during the grace period, the system won't get locked.
          timeout = lockTimeout - config.programs.hyprlock.settings.general.grace;
          on-timeout = hyprlockExe;
        }
        {
          # After we are locked, if no more movement is detected after
          # `dpmsTimeout`, turn off the displays.
          timeout = lockTimeout + dpmsTimeout;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
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
