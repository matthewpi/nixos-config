{
  fetchFromGitHub,
  lib,
  stdenv,
  zsh,
}:
stdenv.mkDerivation rec {
  pname = "zsh-titles";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "amyreese";
    repo = "zsh-titles";
    rev = "116324bb384cc10b66eea5875782051e492e27e1";
    hash = "sha256-f22ND+A01/4uPwZf4N5zsJRjVgJTgXu3UVGuSe/Atn0=";
  };

  strictDeps = true;
  buildInputs = [zsh];

  installPhase = ''
    install -D 'titles.plugin.zsh' "$out/share/${pname}/titles.plugin.zsh"
  '';

  meta = {
    description = "Terminal/tmux titles based on current location and task";
    homepage = "https://github.com/amyreese/zsh-titles";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [matthewpi];
    platforms = lib.platforms.all;
  };
}
