{
  fetchzip,
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "monaspace";
  version = "1.200";

  src = fetchzip {
    url = "https://github.com/githubnext/monaspace/releases/download/v${finalAttrs.version}/monaspace-v${finalAttrs.version}.zip";
    hash = "sha256-j1xQYVxfTNDVuzCKvT5FbU29t8XsH4XqcZ477sjydts=";
    stripRoot = false;
  };

  outputs = ["out" "otf" "ttf" "woff" "woff2"];

  installPhase = ''
    runHook preInstall

    cd monaspace-v${finalAttrs.version}

    for family in Argon Krypton Neon Radon; do
      install -Dm644 fonts/otf/Monaspace"$family"-*.otf -t "$otf"/share/fonts/opentype/Monaspace"$family"

      install -Dm644 fonts/frozen/Monaspace"$family"Frozen-*.ttf -t "$ttf"/share/fonts/truetype
      install -Dm644 fonts/variable/Monaspace"$family"VarVF'[wght,wdth,slnt]'.ttf -t "$ttf"/share/fonts/truetype

      install -Dm644 fonts/webfonts/Monaspace"$family"-*.woff -t "$woff"/share/fonts/woff/Monaspace"$family"
      install -Dm644 fonts/webfonts/Monaspace"$family"VarVF'[wght,wdth,slnt]'.woff -t "$woff"/share/fonts/woff

      install -Dm644 fonts/webfonts/Monaspace"$family"-*.woff2 -t "$woff2"/share/fonts/woff2/Monaspace"$family"
      install -Dm644 fonts/webfonts/Monaspace"$family"VarVF'[wght,wdth,slnt]'.woff2 -t "$woff2"/share/fonts/woff2
    done

    mkdir -p "$out"/share/fonts
    ln -s "$otf"/share/fonts/opentype "$out"/share/fonts/opentype
    ln -s "$ttf"/share/fonts/truetype "$out"/share/fonts/truetype
    ln -s "$woff"/share/fonts/woff "$out"/share/fonts/woff
    ln -s "$woff2"/share/fonts/woff2 "$out"/share/fonts/woff2

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
    outputsToInstall = finalAttrs.outputs;
  };
})
