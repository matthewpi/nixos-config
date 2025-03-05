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
        PartOf = [config.wayland.systemd.target];
        After = [config.wayland.systemd.target];
      };

      Install.WantedBy = [config.wayland.systemd.target];

      Service = {
        Type = "simple";
        ExecStart = "${cfg.package}/libexec/hyprpolkitagent";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
        Slice = "session.slice";
      };
    };
  };
}
