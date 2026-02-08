{
  config,
  lib,
  nixosConfig,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [libsecret];

  services.gnome-keyring = {
    enable = true;
    components = ["pkcs11" "secrets"];
  };

  systemd.user.services.gnome-keyring.Service = let
    exe =
      if nixosConfig.services.gnome.gnome-keyring.enable
      then "/run/wrappers/bin/gnome-keyring-daemon"
      else lib.getExe config.services.gnome-keyring.package;
  in {
    Slice = "session.slice";
    ExecStart = lib.mkForce "${exe} --start --foreground --components=${builtins.concatStringsSep "," config.services.gnome-keyring.components}";
  };
}
