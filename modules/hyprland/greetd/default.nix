{
  config,
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
      command = "${lib.getExe pkgs.greetd.tuigreet} --time";
    };
  };

  # Disable fprint auth for greetd.
  #
  # greetd is used immediately after boot to start a user session. If
  # fingerprint auth is used, gnome-keyring won't get unlocked, requiring a
  # password later anyways. So to avoid this, just use a password instead.
  #
  # A fingerprint can still be used with other services once the user session
  # has been started.
  # security.pam.services.greetd.fprintAuth = false;

  systemd.services.greetd.serviceConfig = lib.mkIf config.services.greetd.enable {
    StandardInput = "tty";
    StandardOutput = "tty";
    # Without this errors will spam on screen
    StandardError = "journal";
    # Without these bootlogs will spam on screen
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  # Force Pipewire to only start for a graphical session. This avoids it starting
  # due to something like SSH or for other users (greeter) that don't actually
  # need it.
  systemd.user.services.pipewire.wantedBy = lib.mkForce ["graphical-session.target"];
}
