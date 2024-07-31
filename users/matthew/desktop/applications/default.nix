{pkgs, ...}: {
  imports = [
    ./audio
    ./communication
    ./development
    ./productivity
    ./security
    ./virtualisation
    ./web

    ./terminal.nix
  ];

  home.packages = with pkgs; [
    impression
    switcheroo
    video-trimmer

    qFlipper
    protonmail-desktop
  ];
}
