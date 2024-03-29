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
    hash = "sha256-DWVFBoICroKaKgByLmDEo4O+xo6eA8YO792g8t8R7kA=";
  };

  strictDeps = true;
  buildInputs = [zsh];

  installPhase = ''
    install -D '_fast-theme' "$out/share/${pname}/_fast-theme"
    install -D 'fast-highlight' "$out/share/${pname}/fast-highlight"
    install -D 'fast-string-highlight' "$out/share/${pname}/fast-string-highlight"
    install -D 'fast-syntax-highlighting.plugin.zsh' "$out/share/${pname}/fast-syntax-highlighting.plugin.zsh"
    install -D 'fast-theme' "$out/share/${pname}/fast-theme"

    for file in themes/*; do
      install -D "$file" "$out/share/${pname}/$file"
    done

    for file in :chroma/*; do
      install -D "$file" "$out/share/${pname}/$file"
    done

    mv "$out/share/${pname}/:chroma" "$out/share/${pname}/→chroma"
  '';

  meta = {
    description = "Feature-rich syntax highlighting for ZSH";
    homepage = "https://github.com/zdharma-continuum/fast-syntax-highlighting";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [matthewpi];
    platforms = lib.platforms.all;
  };
}
