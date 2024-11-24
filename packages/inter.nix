{
  fetchzip,
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation rec {
  pname = "inter";
  version = "4.1";

  src = fetchzip {
    url = "https://github.com/rsms/inter/releases/download/v${version}/Inter-${version}.zip";
    hash = "sha256-5vdKKvHAeZi6igrfpbOdhZlDX2/5+UvzlnCQV6DdqoQ=";
    stripRoot = false;
  };

  outputs = ["out" "otf" "ttf" "woff2"];

  installPhase = ''
    runHook preInstall

    install -Dm644 Inter.ttc -t "$ttf"/share/fonts/truetype
    install -Dm644 InterVariable.ttf InterVariable-Italic.ttf -t "$ttf"/share/fonts/truetype/Inter

    install -Dm644 extras/otf/*.otf -t "$otf"/share/fonts/opentype/Inter
    install -Dm644 extras/ttf/*.ttf -t "$ttf"/share/fonts/truetype/Inter
    install -Dm644 web/*.woff2 -t "$woff2"/share/fonts/woff2/Inter

    mkdir -p "$out"/share/fonts
    ln -s "$otf"/share/fonts/opentype "$out"/share/fonts/opentype
    ln -s "$ttf"/share/fonts/truetype "$out"/share/fonts/truetype
    ln -s "$woff2"/share/fonts/woff2 "$out"/share/fonts/woff2

    runHook postInstall
  '';

  meta = {
    homepage = "https://rsms.me/inter/";
    description = "A typeface specially designed for user interfaces";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [matthewpi];
  };
}
