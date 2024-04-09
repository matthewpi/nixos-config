{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.hyprpaper.homeManagerModules.hyprpaper
  ];

  services.hyprpaper = let
    wallpaper = "${pkgs.catppuccin-wallpapers}/nix-black-4k.png";
  in {
    enable = true;
    ipc = false;
    splash = false;
    # yes the extra comma here is intentional, it makes the wallpaper appear on all monitors.
    wallpapers = [",${wallpaper}"];
    preloads = [wallpaper];
  };

  systemd.user.services.hyprpaper = {
    Service.Slice = "session.slice";
    Unit.PartOf = lib.mkForce ["hyprland-session.target"];
    Install.WantedBy = lib.mkForce ["hyprland-session.target"];
  };
}
