{
  callPackage,
  fetchurl,
  lib,
  stdenv,
}: let
  pname = "cider";
  version = "2.5.0";

  # For anyone wondering, these files are locked behind firewall rules.
  # If you want Cider2, go buy it yourself.
  sources = {
    aarch64-darwin = {
      url = "https://r2.matthewp.io/cider/${version}/Cider-${version}-aarch64.dmg";
      hash = "sha256-3dwEuRR8t9Wq3jaJM+ywZmbTBlBbLgX+04kzn+xPq50=";
    };
    x86_64-darwin = {
      url = "https://r2.matthewp.io/cider/${version}/Cider-${version}-x86_64.dmg";
      hash = "sha256-km0N+xRV3ot+4d524oP0wb/vti5P/v3GIvSXMhbuy+E=";
    };
    x86_64-linux = {
      url = "https://r2.matthewp.io/cider/${version}/Cider-${version}.AppImage";
      hash = "sha256-HwfByY8av1AvI+t7wnaNbhDLXBxgzRKYiLG1hPUto9o=";
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
