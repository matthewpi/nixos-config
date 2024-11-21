{
  lib,
  pkgs,
  ...
}: let
  wallpaper = "${pkgs.catppuccin-wallpapers}/CatppuccinMocha-Kurzgesagt-CloudyQuasar1.png";
in {
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = false;
      splash = false;
      preload = [wallpaper];
      # The comma here causes the same wallpaper to be rendered on all monitors.
      wallpaper = [",${wallpaper}"];
    };
  };

  systemd.user.services.hyprpaper = {
    Service.Slice = "session.slice";
    Unit.PartOf = lib.mkForce ["hyprland-session.target"];
    Install.WantedBy = lib.mkForce ["hyprland-session.target"];
  };
}
