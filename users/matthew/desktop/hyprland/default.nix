{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.hyprland.homeManagerModules.default

    ./hypridle.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./xdg.nix

    inputs.ags.homeManagerModules.default
    ../../../../modules/ags
  ];

  home.packages = with pkgs; [
    # GNOME
    epiphany
    evince
    dconf-editor
    file-roller
    geary
    gnome-calculator
    gnome-calendar
    gnome-characters
    gnome-clocks
    gnome-contacts
    gnome-disk-utility
    gnome-font-viewer
    gnome-logs
    gnome-maps
    gnome-text-editor
    gnome-weather
    loupe
    nautilus
    seahorse
    sushi
    totem
    # wordbook

    # clipboard
    wl-clipboard

    (makeAutostartItem {
      name = "1password";
      package = _1password-gui-beta;
    })
  ];

  services.polkit = {
    enable = true;
    # TODO: switch to `hypr` once we can figure out why it isn't sized correctly.
    agent = "gnome";
  };
}
