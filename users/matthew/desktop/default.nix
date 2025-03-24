{pkgs, ...}: {
  imports = [
    ./applications
    ./hyprland
    ./services

    ./gtk.nix
    ./mime.nix
  ];

  home.packages = with pkgs; [
    # Install nvtop
    nvtopPackages.amd
  ];
}
