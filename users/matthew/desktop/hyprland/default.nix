{
  inputs,
  isDesktop,
  lib,
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
  ];

  services.polkit = {
    enable = true;
    # TODO: switch to `hypr` once we can figure out why it isn't sized correctly.
    agent = "gnome";
  };

  xdg.autostart = {
    enable = true;
    entries = let
      _1password = pkgs.makeAutostartItem {
        name = "1password";
        package = nixosConfig.programs._1password-gui.package;
        # Do not open a window when started. This causes 1Password to only appear
        # in the tray where it can then be unlocked later.
        prependExtraArgs = ["--silent"];
      };
    in
      []
      ++ lib.optional nixosConfig.programs._1password-gui.enable "${_1password}/etc/xdg/autostart/1password.desktop"
      ++ lib.optional isDesktop "${pkgs.polychromatic}/etc/xdg/autostart/polychromatic-autostart.desktop";
  };
}
