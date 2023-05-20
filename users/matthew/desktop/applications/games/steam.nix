{pkgs, ...}: let
  steam-with-pkgs = pkgs.steam.override {
    # extraEnv = {
    #   OBS_VKCAPTURE = true;
    # };

    extraPkgs = pkgs:
      with pkgs; [
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
        libkrb5
        keyutils
      ];
  };
in {
  home.packages = with pkgs; [
    steam-with-pkgs
    steam-with-pkgs.run
    gamescope
    mangohud
  ];
}
