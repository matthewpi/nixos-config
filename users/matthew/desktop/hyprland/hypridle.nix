{
  lib,
  nixosConfig,
  ...
}: {
  # https://wiki.hyprland.org/Hypr-Ecosystem/hypridle/
  services.hypridle = let
    # Grace period where the lock can be interrupted by moving the mouse or
    # typing on the keyboard. This grace period only occurs if the lock was
    # caused by lock timeout and a call to `loginctl lock-session`.
    graceSeconds = 5;

    # Inactivity timeout until the system auto-locks after, assuming no lock
    # inhibitors are active.
    lockTimeout = 300;

    # dpms timeout is stacked on top of lock timeout.
    dpmsTimeout = 30;
  in {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "${lib.getExe' nixosConfig.systemd.package "loginctl"} lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          # Remove the grace period from hyprlock so we can have a visual
          # indicator that the system is about to be locked. If movement is
          # detected during the grace period, the system won't get locked.
          timeout = lockTimeout - graceSeconds;
          # We use hyprlock here without `--immediate` so that hyprlock's grace
          # period works.
          on-timeout = "hyprlock --grace ${toString graceSeconds}";
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

  systemd.user.services.hypridle.Service.Slice = "session.slice";
}
