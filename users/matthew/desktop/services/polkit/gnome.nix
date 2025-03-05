{
  config,
  lib,
  ...
}: let
  cfg = config.services.polkit;
in {
  config = lib.mkIf (cfg.enable && cfg.agent == "gnome") {
    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      Unit = {
        Description = "Polkit GNOME Authentication Agent";
        PartOf = [config.wayland.systemd.target];
        After = [config.wayland.systemd.target];
      };

      Install.WantedBy = [config.wayland.systemd.target];

      Service = {
        Type = "simple";
        ExecStart = "${cfg.package}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
        Slice = "session.slice";
      };
    };
  };
}
