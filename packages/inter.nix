{
  fetchzip,
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation rec {
  pname = "inter";
  version = "4.0";

  src = fetchzip {
    url = "https://github.com/rsms/inter/releases/download/v${version}/Inter-${version}.zip";
    hash = "sha256-hFK7xFJt69n+98+juWgMvt+zeB9nDkc8nsR8vohrFIc=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    ls -lsA .

    install -Dm644 Inter.ttc -t "$out/share/fonts/truetype"
    install -Dm644 InterVariable.ttf InterVariable-Italic.ttf -t "$out/share/fonts/truetype/Inter"

    install -Dm644 extras/otf/*.otf -t "$out/share/fonts/opentype/Inter"
    install -Dm644 extras/ttf/*.ttf -t "$out/share/fonts/truetype/Inter"
    install -Dm644 web/*.woff2 -t "$out/share/fonts/woff2/Inter"

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://rsms.me/inter/";
    description = "A typeface specially designed for user interfaces";
    license = licenses.ofl;
    platforms = platforms.all;
    maintainers = with maintainers; [matthewpi];
  };
}
