{pkgs, ...}: {
  services.hyprpaper = let
    wallpaper = "${pkgs.catppuccin-wallpapers}/CatppuccinMocha-Kurzgesagt-CloudyQuasar1.png";
  in {
    enable = true;
    settings = {
      ipc = false;
      splash = false;
      preload = [wallpaper];
      # The comma here causes the same wallpaper to be rendered on all monitors.
      wallpaper = [",${wallpaper}"];
    };
  };

  systemd.user.services.hyprpaper.Service.Slice = "session.slice";
}
