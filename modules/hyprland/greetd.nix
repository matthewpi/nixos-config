{
  config,
  lib,
  pkgs,
  ...
}: {
  # Enable greetd
  services.greetd = {
    enable = lib.mkDefault true;
    restart = lib.mkDefault true;
    settings = rec {
      # Configure a session for Hyprland, the greeter (regreet in this case) will use it as one of
      # the available session options. We can add additional sessions in this config if needed.
      hyprland = {
        command = "${lib.getExe config.programs.hyprland.package}";
        # TODO: is user needed here?
        #user = "matthew";
      };

      # The default session launches regreet under cage (a wayland kiosh compositor)
      default_session = {
        command = "${lib.getExe pkgs.cage} ${lib.escapeShellArgs config.programs.regreet.cageArgs} -- ${lib.getExe config.programs.regreet.package}";
        user = "greeter";
      };
    };
  };

  # Enable regreet, a GTK greeter for greetd.
  programs.regreet = {
    enable = lib.mkDefault true;

    # Defaults to ["-s"], but we add the `["-m" "last"]` argument to
    # force cage to only use the last connected output. Otherwise
    # cage will span across all displays which is not wanted.
    #
    # The other option is to use a tool like `wlr-randr` that uses the
    # `wlr-output-management` protocol to allow the configuration of
    # displays.
    cageArgs = lib.mkDefault ["-s" "-m" "last"];

    settings = {
      GTK = {
        # Enable regreet's dark theme.
        application_prefer_dark_theme = lib.mkDefault true;
      };
    };
  };

  # Override the default greetd unit to properly handle plymouth.
  #
  # The upstream unit in nixpkgs causes Plymouth to be visible, then disappear
  # causing the TTY to be shown before greetd has started.
  #  systemd.services.greetd.unitConfig = let
  #    tty = "tty@${toString config.services.greetd.vt}";
  #  in {
  #    After = lib.mkDefault [
  #      "systemd-user-sessions.service"
  #      "getty@${tty}.service"
  #      "plymouth-start.service"
  #      "plymouth-quit.service"
  #    ];
  #    Wants = ["systemd-user-sessions.service"];
  #    Conflicts = ["getty@${tty}.service"];
  #    OnFailure = ["plymouth-quit.service"];
  #  };

  # Prevent nixos-rebuild switch from bringing down the graphical
  # session. (If multi-user.target wants plymouth-quit.service which
  # conflicts greetd.service, then when nixos-rebuild
  # switch starts multi-user.target, greetd.service is
  # stopped so plymouth-quit.service can be started)
  #  systemd.services.plymouth-quit = lib.mkIf config.boot.plymouth.enable {
  #    wantedBy = lib.mkForce [];
  #  };
}
