{
  fetchFromGitHub,
  lib,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "catppuccin-k9s";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "k9s";
    rev = "322598e19a4270298b08dc2765f74795e23a1615";
    hash = "sha256-GrRCOwCgM8BFhY8TzO3/WDTUnGtqkhvlDWE//ox2GxI=";
  };

  configurePhase = ''
    mkdir -p $out
  '';

  buildPhase = "";

  installPhase = ''
    cp dist/frappe.yml $out/frappe.yaml
    cp dist/latte.yml $out/latte.yaml
    cp dist/macchiato.yml $out/macchiato.yaml
    cp dist/mocha.yml $out/mocha.yaml
  '';

  meta = {
    description = "Soothing pastel theme for k9s";
    homepage = "https://github.com/catppuccin/k9s";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [matthewpi];
  };
}
