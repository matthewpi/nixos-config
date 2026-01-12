{
  config,
  pkgs,
  ...
}: {
  home.packages = [pkgs.flatpak];

  xdg.systemDirs.data = [
    "${config.xdg.dataHome}/flatpak/exports"
    "/var/lib/flatpak/exports"
  ];
}
