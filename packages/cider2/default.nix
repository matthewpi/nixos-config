{
  callPackage,
  fetchurl,
  lib,
  stdenv,
}: let
  pname = "cider";
  version = "2.4.1";

  # For anyone wondering, these files are locked behind firewall rules.
  # If you want Cider2, go buy it yourself.
  sources = {
    aarch64-darwin = {
      url = "https://r2.matthewp.io/cider/${version}/Cider-${version}-aarch64.dmg";
      hash = "sha256-wpVPebFiruUD9U/bHHN3CMMWIvjzO2K3tLYP9KGPNPk=";
    };
    x86_64-darwin = {
      url = "https://r2.matthewp.io/cider/${version}/Cider-${version}-x86_64.dmg";
      hash = "sha256-mGozZoNiFjUQURMZIROItJbhKHNit9pyChoaYVPzqZU=";
    };
    x86_64-linux = {
      url = "https://r2.matthewp.io/cider/${version}/Cider-${version}.AppImage";
      hash = "sha256-p1NH11+QvkhXrPnfsozsbmrY4ZkyVQ1wcFqLkmV+R7c=";
    };
  };

  src = fetchurl {
    inherit (sources.${stdenv.system}) url hash;
  };

  meta = {
    mainProgram = "cider";
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
