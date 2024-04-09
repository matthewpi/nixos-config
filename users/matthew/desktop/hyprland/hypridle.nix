{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.hypridle.homeManagerModules.default
  ];

  # https://wiki.hyprland.org/Hypr-Ecosystem/hypridle/
  services.hypridle = let
    hyprlockExe = lib.getExe config.programs.hyprlock.package;
  in {
    enable = true;
    package = pkgs.hypridle;

    listeners = [
      {
        timeout = 300;
        onTimeout = hyprlockExe;
        onResume = "";
      }
    ];

    lockCmd = hyprlockExe;
    beforeSleepCmd = hyprlockExe;
    unlockCmd = "";
    afterSleepCmd = "";
  };

  systemd.user.services.hypridle = {
    Service.Slice = "session.slice";
    Unit.After = lib.mkForce [];
    Unit.PartOf = lib.mkForce ["hyprland-session.target"];
    Install.WantedBy = lib.mkForce ["hyprland-session.target"];
  };
}
