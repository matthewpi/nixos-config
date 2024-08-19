{
  pname,
  version,
  src,
  meta,
  stdenv,
  undmg,
  unzip,
}:
stdenv.mkDerivation {
  inherit pname version src meta;

  nativeBuildInputs = [undmg unzip];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p "$out"/Applications
    cp -r *.app "$out"/Applications
  '';
}
