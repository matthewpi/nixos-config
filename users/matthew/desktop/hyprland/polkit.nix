{pkgs, ...}: {
  # Add a systemd user service for the GNOME polkit agent.
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "Polkit GNOME Authentication Agent";
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
      Slice = "session.slice";
    };

    Install = {
      WantedBy = ["hyprland-session.target"];
    };
  };
}
