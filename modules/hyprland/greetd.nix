{
  lib,
  pkgs,
  ...
}: {
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
      command = "${lib.getExe pkgs.greetd.tuigreet} --time";
      user = "greeter";
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
  security.pam.services.greetd.fprintAuth = false;
}
