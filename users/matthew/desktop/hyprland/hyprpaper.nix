{pkgs, ...}: {
  # https://wiki.hyprland.org/Hypr-Ecosystem/hyprpaper/
  # https://github.com/hyprwm/hyprpaper/tree/main?tab=readme-ov-file#usage
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    # Disable IPC, we only staticly set a wallpaper and never use IPC.
    ipc = off

    # Disable splash
    splash = off

    # Preload and set the wallpaper
    preload = ${pkgs.catppuccin-wallpapers}/nix-black-4k.png
    wallpaper = ,${pkgs.catppuccin-wallpapers}/nix-black-4k.png
  '';
}
