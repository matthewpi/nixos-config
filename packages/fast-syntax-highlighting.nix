{
  fetchFromGitHub,
  lib,
  stdenv,
  zsh,
}:
stdenv.mkDerivation rec {
  pname = "fast-syntax-highlighting";
  version = "1.55";

  src = fetchFromGitHub {
    owner = "zdharma-continuum";
    repo = "fast-syntax-highlighting";
    rev = "v${version}";
    sha256 = "sha256-DWVFBoICroKaKgByLmDEo4O+xo6eA8YO792g8t8R7kA=";
  };

  strictDeps = true;
  buildInputs = [zsh];

  installPhase = ''
    install -D _fast-theme $out/share/fast-syntax-highlighting/_fast-theme
    install -D fast-highlight $out/share/fast-syntax-highlighting/fast-highlight
    install -D fast-string-highlight $out/share/fast-syntax-highlighting/fast-string-highlight
    install -D fast-syntax-highlighting.plugin.zsh $out/share/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
    install -D fast-theme $out/share/fast-syntax-highlighting/fast-theme

    for file in themes/*; do
      install -D "$file" "$out/share/fast-syntax-highlighting/$file"
    done

    for file in :chroma/*; do
      install -D "$file" "$out/share/fast-syntax-highlighting/$file"
    done

    mv $out/share/fast-syntax-highlighting/:chroma $out/share/fast-syntax-highlighting/→chroma
  '';

  meta = {
    description = "Feature-rich syntax highlighting for ZSH";
    homepage = "https://github.com/zdharma-continuum/fast-syntax-highlighting";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [matthewpi];
  };
}
