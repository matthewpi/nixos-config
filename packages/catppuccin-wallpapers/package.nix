{
  fetchFromGitHub,
  lib,
  stdenv,
}:
stdenv.mkDerivation {
  pname = "catppuccin-wallpapers";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "DragonDev07";
    repo = "Wallpapers";
    rev = "45cf2505cc6523f1d17d378e23c577839732f971";
    hash = "sha256-ztErvSKkcvB7KjzvejMisClS6Kcak9ZPuHNmxO0zUbs=";
  };

  strictDeps = true;

  installPhase = ''
    mkdir -p "$out"
    install -Dm444 Catppuccin/Mocha/CatppuccinMocha-Kurzgesagt-*.png "$out"
  '';

  meta = {
    maintainers = with lib.maintainers; [matthewpi];
    platforms = lib.platforms.all;
  };
}
