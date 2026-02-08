{
  config,
  lib,
  pkgs,
  ...
}: {
  services.hyprpaper = let
    wallpaper = "${pkgs.catppuccin-wallpapers}/CatppuccinMocha-Kurzgesagt-CloudyQuasar1.png";
  in {
    enable = true;
    importantPrefixes = ["monitor"];
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

  systemd.user.services.hyprpaper = {
    Unit = {
      Before = [config.wayland.systemd.target];
      After = lib.mkForce [];
    };
    Service.Slice = "session.slice";
  };
}
