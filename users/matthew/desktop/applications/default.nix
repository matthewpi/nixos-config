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
    apostrophe
    # Disabled due to build failure.
    # collision
    eartag
    errands
    eyedropper
    fragments
    impression
    switcheroo
    video-trimmer
    wike

    qFlipper
    protonmail-desktop
  ];
}
