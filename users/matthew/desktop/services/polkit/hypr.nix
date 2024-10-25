{
  config,
  lib,
  ...
}: let
  cfg = config.services.polkit;
in {
  config = lib.mkIf (cfg.enable && cfg.agent == "hypr") {
    systemd.user.services.hyprpolkitagent = {
      Unit = {
        Description = "Hyprland Polkit Authentication Agent";
        # PartOf = ["graphical-session.target"];
        # After = ["graphical-session.target"];
      };

      Service = {
        Type = "simple";
        ExecStart = "${cfg.package}/libexec/hyprpolkitagent";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
        Slice = "session.slice";
      };

      Install = {
        # WantedBy = ["graphical-session.target"];
        WantedBy = ["hyprland-session.target"];
      };
    };
  };
}
