{pkgs, ...}: {
  imports = [
    ./applications
    ./services

    ./gtk.nix
    ./streamdeck.nix
  ];
}
