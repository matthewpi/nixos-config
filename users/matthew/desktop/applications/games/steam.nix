{pkgs, ...}: let
  steam-with-pkgs = pkgs.steam.override {
    extraEnv = {
      # Manually set SDL_VIDEODRIVER to x11.
      #
      # This fixes the `gldriverquery` segfault and issues with EAC crashing on games like Rust,
      # rather than gracefully disabling itself.
      SDL_VIDEODRIVER = "x11";
      #OBS_VKCAPTURE = true;
    };

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
