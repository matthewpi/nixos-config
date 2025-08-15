{
  lib,
  pkgs,
  ...
}: {
  disabledModules = ["services/display-managers/greetd.nix"];
  imports = [./module.nix];

  # Enable greetd.
  services.greetd = {
    enable = lib.mkDefault true;
    restart = lib.mkDefault true;

    # Configure tuigreet as the greeter.
    #
    # Ideally I'd like something a bit nicer, but AGS broke and tuigreet works,
    # so for now we will use it :)
    #
    # For those wondering how this triggers Hyprland, it detects a list of
    # available sessions from `config.services.displayManager.sessionPackages`.
    settings.default_session = {
      user = "greeter";
      command = "${lib.getExe pkgs.tuigreet} --time";
    };
  };

  # Force Pipewire to only start for a graphical session. This avoids it starting
  # due to something like SSH or for other users (greeter) that don't actually
  # need it.
  systemd.user.services.pipewire.wantedBy = lib.mkForce ["graphical-session.target"];
  systemd.user.services.pipewire-pulse.wantedBy = lib.mkForce ["graphical-session.target"];
}
