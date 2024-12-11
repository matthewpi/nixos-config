{pkgs, ...}: {
  imports = [
    ./applications
    ./hyprland
    ./services

    ./gtk.nix
    ./mime.nix
    ./streamdeck.nix
  ];

  # https://nix-community.github.io/home-manager/options.xhtml#opt-systemd.user.startServices
  systemd.user.startServices = "sd-switch";

  home.packages = with pkgs; [
    # Install nvtop
    nvtopPackages.amd
  ];
}
