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

    ../../../../modules/ags
  ];

  home.packages = with pkgs; [
    # GNOME
    bustle
    celluloid
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
    papers
    seahorse
    showtime
    sushi

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
