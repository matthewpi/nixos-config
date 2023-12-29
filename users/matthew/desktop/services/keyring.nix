{pkgs, ...}: {
  services.gnome-keyring = {
    enable = true;
    components = ["pkcs11" "secrets"];
  };
  systemd.user.services.gnome-keyring.Service.Slice = "session.slice";

  home.packages = with pkgs; [libsecret];
}
