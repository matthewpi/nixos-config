{lib, ...}: {
  # Enable dconf
  programs.dconf.enable = lib.mkDefault true;
  systemd.user.services.dconf.serviceConfig.Slice = "session.slice";
}
