{config, ...}: {
  # https://wiki.hyprland.org/Hypr-Ecosystem/hypridle/
  services.hypridle = let
    # `pidof` here prevents multiple hyprlock instances from running simultaneously.
    hyprlockExe = "pidof hyprlock || hyprlock";

    lockTimeout = 300;

    # dpms timeout is stacked on top of lock timeout.
    dpmsTimeout = 30;
  in {
    enable = true;
    settings = {
      general = {
        lock_cmd = "${hyprlockExe} --immediate";
        before_sleep_cmd = "${hyprlockExe} --immediate --immediate-render --no-fade-in";
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        # ignore_systemd_inhibit = false;
      };

      listener = [
        {
          # Remove the grace period from hyprlock so we can have a visual
          # indicator that the system is about to be locked. If movement is
          # detected during the grace period, the system won't get locked.
          timeout = lockTimeout - config.programs.hyprlock.settings.general.grace;
          # We use hyprlock here without `--immediate` so that hyprlock's grace
          # period works.
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

  systemd.user.services.hypridle.Service.Slice = "session.slice";
}
