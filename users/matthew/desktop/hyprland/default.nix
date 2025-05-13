{
  inputs,
  nixosConfig,
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
    bustle
    celluloid
    epiphany
    evince
    dconf-editor
    file-roller
    fragments
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
    showtime
    sushi
    # wordbook

    # clipboard
    wl-clipboard

    (makeAutostartItem {
      name = "1password";
      package = nixosConfig.programs._1password-gui.package;
    })
  ];

  services.polkit = {
    enable = true;
    # TODO: switch to `hypr` once we can figure out why it isn't sized correctly.
    agent = "gnome";
  };
}
