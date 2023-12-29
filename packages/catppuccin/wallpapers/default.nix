{
  lib,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "catppuccin-wallpapers";
  version = "1.0.0";

  src = lib.cleanSource ./.;

  strictDeps = true;

  installPhase = ''
    install -D nix-black-4k.png $out/nix-black-4k.png
    install -D nix-magenta-blue-1920x1080.png $out/nix-magenta-blue-1920x1080.png
    install -D nix-magenta-pink-1920x1080.png $out/nix-magenta-pink-1920x1080.png
  '';

  meta = {
    maintainers = with lib.maintainers; [matthewpi];
    platforms = lib.platforms.all;
  };
}
