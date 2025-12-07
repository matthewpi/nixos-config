{pkgs, ...}: {
  services.hyprpaper = let
    wallpaper = "${pkgs.catppuccin-wallpapers}/CatppuccinMocha-Kurzgesagt-CloudyQuasar1.png";
  in {
    enable = true;
    settings = {
      ipc = true;
      splash = false;
      wallpaper = [
        {
          monitor = "";
          path = wallpaper;
          fit_mode = "fill";
        }
      ];
    };
  };

  systemd.user.services.hyprpaper.Service.Slice = "session.slice";
}
