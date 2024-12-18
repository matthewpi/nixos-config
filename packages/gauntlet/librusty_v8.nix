{
  fetchurl,
  lib,
  stdenv,
}: let
  fetchLibrustyV8 = args:
    fetchurl {
      name = "librusty_v8-${args.version}";
      url = "https://github.com/denoland/rusty_v8/releases/download/v${args.version}/librusty_v8_release_${stdenv.hostPlatform.rust.rustcTarget}.a.gz";
      hash = args.shas.${stdenv.hostPlatform.system};
      meta = {
        inherit (args) version;
        sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      };
    };
in
  fetchLibrustyV8 {
    version = "130.0.2";
    shas = {
      x86_64-linux = "sha256-ew2WZhdsHfffRQtif076AWAlFohwPo/RbmW/6D3LzkU=";
      aarch64-linux = lib.fakeHash;
      x86_64-darwin = lib.fakeHash;
      aarch64-darwin = lib.fakeHash;
    };
  }
