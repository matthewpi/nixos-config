{pkgs, ...}: {
  imports = [
    ./applications
    ./hyprland
    ./services

    ./gtk.nix
    ./mime.nix
    ./podman.nix
    ./streamdeck.nix
  ];

  home.packages = with pkgs; [
    # Install nvtop
    nvtopPackages.amd

    # Install kind
    kind

    # Install devenv
    devenv
  ];
}
