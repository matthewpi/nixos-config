{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.hyprland.homeManagerModules.default
    inputs.hypridle.homeManagerModules.default
    inputs.hyprlock.homeManagerModules.default

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
    gnome.dconf-editor
    gnome.eog
    gnome.file-roller
    gnome.geary
    gnome.gnome-calculator
    gnome.gnome-calendar
    gnome.gnome-characters
    gnome.gnome-clocks
    gnome.gnome-contacts
    gnome.gnome-dictionary
    gnome.gnome-disk-utility
    gnome.gnome-font-viewer
    gnome.gnome-logs
    gnome.gnome-maps
    gnome.gnome-system-monitor
    gnome.gnome-weather
    gnome.nautilus
    gnome.seahorse
    gnome.sushi
    gnome.totem
    gnome-text-editor

    # Hyprland
    hyprpicker

    # clipboard
    wl-clipboard
  ];

  # QT Theming
  qt = {
    enable = true;
    platformTheme = "gtk";
    style.name = "adwaita-dark";
  };
}
