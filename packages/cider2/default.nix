{
  callPackage,
  fetchurl,
  lib,
  stdenv,
}: let
  pname = "cider2";
  version = "2.6.0";

  # For anyone wondering, these files are locked behind firewall rules.
  # If you want Cider2, go buy it yourself.
  sources = {
    aarch64-darwin = {
      url = "https://r2.matthewp.io/cider/${version}/Cider-${version}-aarch64.dmg";
      hash = "sha256-Id68REE2BsH0VSCokKQ4TMo7kDseudgctzpvntf59iI=";
    };
    x86_64-darwin = {
      url = "https://r2.matthewp.io/cider/${version}/Cider-${version}-x86_64.dmg";
      hash = "sha256-5R71A8DBYyZ7LHJits1OQgH2Dri95P1PjaZ+mTkQjyM=";
    };
    x86_64-linux = {
      url = "https://r2.matthewp.io/cider/${version}/Cider-${version}.AppImage";
      hash = "sha256-OMsLuqJPEPzjDjyEqq+y0c3gdAvFxiCLasa7X2MhbYY=";
    };
  };

  src = fetchurl {
    inherit (sources.${stdenv.system}) url hash;
  };

  meta = {
    mainProgram = "cider2";
    description = "Cross-platform Apple Music client";
    homepage = "https://cider.sh/";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [matthewpi];
    platforms = builtins.attrNames sources;
    sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
  };
in
  if stdenv.isDarwin
  then callPackage ./darwin.nix {inherit pname version src meta;}
  else callPackage ./linux.nix {inherit pname version src meta;}
