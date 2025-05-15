{
  config,
  lib,
  pkgs,
  ...
}: {
  # Enable ratbagd
  services.ratbagd.enable = lib.mkDefault true;

  # Install piper if ratbagd is enabled
  environment.systemPackages = lib.optional config.services.ratbagd.enable pkgs.piper;
}
