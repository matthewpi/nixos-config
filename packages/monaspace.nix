{
  fetchzip,
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation rec {
  pname = "monaspace";
  version = "1.000";

  src = fetchzip {
    url = "https://github.com/githubnext/${pname}/releases/download/v${version}/${pname}-v${version}.zip";
    hash = "sha256-H8NOS+pVkrY9DofuJhPR2OlzkF4fMdmP2zfDBfrk83A=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    for family in Argon Krypton Neon Radon; do
      install -Dm644 ${pname}-v${version}/fonts/otf/Monaspace''${family}-*.otf -t "$out/share/fonts/opentype/Monaspace''${family}"

      install -Dm644 "${pname}-v${version}/fonts/variable/Monaspace''${family}VarVF[wght,wdth,slnt].ttf" -t "$out/share/fonts/truetype"

      install -Dm644 ${pname}-v${version}/fonts/webfonts/Monaspace''${family}-*.woff -t "$out/share/fonts/woff/Monaspace''${family}"
      install -Dm644 "${pname}-v${version}/fonts/webfonts/Monaspace''${family}VarVF[wght,wdth,slnt].woff" -t "$out/share/fonts/woff"

      install -Dm644 "${pname}-v${version}/fonts/webfonts/Monaspace''${family}VarVF[wght,wdth,slnt].woff2" -t "$out/share/fonts/woff2"
    done

    runHook postInstall
  '';

  meta = {
    description = "An innovative superfamily of fonts for code";
    longDescription = ''
      Since the earliest days of the teletype machine, code has been set in
      monospaced type — letters, on a grid. Monaspace is a new type system that
      advances the state of the art for the display of code on screen.
      Every advancement in the technology of computing has been accompanied by
      advancements to the display and editing of code. CRTs made screen editors
      possible. The advent of graphical user interfaces gave rise to integrated
      development environments.
      Even today, we still have limited options when we want to layer additional
      meaning on top of code. Syntax highlighting was invented in 1982 to help
      children to code in BASIC. But beyond colors, most editors must
      communicate with developers through their interfaces — hovers, underlines,
      and other graphical decorations.
      Monaspace offers a more expressive palette for code and the tools we use
      to work with it.
    '';
    homepage = "https://monaspace.githubnext.com/";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [matthewpi];
    platforms = lib.platforms.all;
  };
}
