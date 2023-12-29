{pkgs, ...}: {
  home.packages = with pkgs; [trayscale];

  dconf.settings."dev/deedles/Trayscale" = {
    tray-icon = false;
  };
}
