{
  callPackage,
  fetchurl,
  lib,
  stdenv,
}: let
  pname = "cider2";
  version = "2.6.1";

  # For anyone wondering, these files are locked behind firewall rules.
  # If you want Cider2, go buy it yourself.
  sources. x86_64-linux = {
    url = "https://r2.matthewp.io/cider/${version}/Cider-${version}.AppImage";
    hash = "sha256-buHunUtFQZ14YNHngx3Hwqm5RonwE6C/SDh2xrTWUGI=";
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
  if stdenv.isLinux
  then callPackage ./linux.nix {inherit pname version src meta;}
  else throw "Unsupported platform: ${stdenv.system}"
