{
  fetchFromGitHub,
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "monaspace";
  version = "1.301";

  src = fetchFromGitHub {
    owner = "githubnext";
    repo = "monaspace";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8tPwm92ZtaXL9qeDL+ay9PdXLUBBsspdk7/0U8VO0Tg=";
  };

  outputs = ["out" "otf" "ttf" "woff" "woff2" "nerdfonts"];

  installPhase = ''
    runHook preInstall

    for family in Argon Krypton Neon Radon; do
      echo 'Installing frozen fonts...'
      install -Dm444 'fonts/Frozen Fonts/Monaspace '"$family"/Monaspace"$family"Frozen-*.ttf -t "$ttf"/share/fonts/truetype/'Monaspace '"$family"' Frozen'
      echo 'Installing nerd fonts...'
      install -Dm444 'fonts/NerdFonts/Monaspace '"$family"/Monaspace"$family"NF-*.otf -t "$nerdfonts"/share/fonts/opentype/'Monaspace '"$family"' NF'
      echo 'Installing static fonts...'
      install -Dm444 'fonts/Static Fonts/Monaspace '"$family"/Monaspace"$family"-*.otf -t "$otf"/share/fonts/opentype/'Monaspace '"$family"
      echo 'Installing variable fonts...'
      install -Dm444 'fonts/Variable Fonts/Monaspace '"$family"/'Monaspace '"$family"' Var'.ttf -t "$ttf"/share/fonts/truetype

      echo 'Installing static web fonts (woff)...'
      install -Dm444 'fonts/Web Fonts/Static Web Fonts/Monaspace '"$family"/Monaspace"$family"-*.woff -t "$woff"/share/fonts/woff/'Monaspace '"$family"
      echo 'Installing static web fonts (woff2)...'
      install -Dm444 'fonts/Web Fonts/Static Web Fonts/Monaspace '"$family"/Monaspace"$family"-*.woff2 -t "$woff2"/share/fonts/woff2/'Monaspace '"$family"

      echo 'Installing variable web fonts (woff)...'
      install -Dm444 'fonts/Web Fonts/Variable Web Fonts/Monaspace '"$family"/'Monaspace '"$family"' Var'.woff -t "$woff"/share/fonts/woff
      echo 'Installing variable web fonts (woff2)...'
      install -Dm444 'fonts/Web Fonts/Variable Web Fonts/Monaspace '"$family"/'Monaspace '"$family"' Var'.woff2 -t "$woff2"/share/fonts/woff2
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
    outputsToInstall = ["otf"];
  };
})
