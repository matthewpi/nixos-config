{config, ...}: {
  # https://nix-community.github.io/home-manager/options.html#opt-systemd.user.startServices
  systemd.user.startServices = "sd-switch";

  systemd.user.services.streamdeck = {
    Unit = {
      Description = "Streamdeck";
    };

    Service = {
      ExecStart = "${config.home.homeDirectory}/code/matthewpi/streamdeck-local/streamdeck"; # TODO: package
      ExecStop = "/bin/kill --signal INT $MAINPID";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
