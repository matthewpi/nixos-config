{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.hyprland.homeManagerModules.default

    inputs.ags.homeManagerModules.default

    ./hypridle.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./polkit.nix
    ./xdg.nix

    ../../../../modules/ags
  ];

  home.packages = with pkgs; [
    # GNOME
    epiphany
    evince
    dconf-editor
    eog
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
    gnome-system-monitor
    gnome-text-editor
    gnome-weather
    nautilus
    seahorse
    sushi
    totem
    wordbook

    # Hyprland
    hyprpicker

    # clipboard
    wl-clipboard
  ];

  # QT Theming
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "adwaita-dark";
  };
}
