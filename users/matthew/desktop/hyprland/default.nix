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
    gnome.gnome-characters
    gnome.gnome-clocks
    gnome.gnome-contacts
    gnome-dictionary
    gnome-disk-utility
    gnome-font-viewer
    gnome.gnome-logs
    gnome.gnome-maps
    gnome-system-monitor
    gnome-text-editor
    gnome.gnome-weather
    nautilus
    seahorse
    sushi
    totem

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
