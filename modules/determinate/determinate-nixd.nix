{
  fetchurl,
  installShellFiles,
  lib,
  stdenvNoCC,
}: let
  hashes = {
    x86_64-linux = "sha256-NIIk5e9R0OQe2EMAEHZ9+rVh9/vEcbvWb+P0xDDqsvU=";
  };

  system = stdenvNoCC.hostPlatform.system;
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "determinate-nixd";
    version = "3.15.1";

    src = fetchurl {
      url = "https://install.determinate.systems/determinate-nixd/tag/v${finalAttrs.version}/${system}";
      hash = hashes.${system} or (throw "unsupported system: ${system}");
      executable = true;
    };

    dontUnpack = true;
    dontBuild = true;

    nativeBuildInputs = [installShellFiles];

    installPhase = ''
      runHook preInstall

      mkdir -p "$out"/bin
      ln -s "$src" "$out"/bin/${finalAttrs.meta.mainProgram}

      runHook postInstall
    '';

    postInstall = lib.optionalString (stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform) ''
      installShellCompletion --cmd ${finalAttrs.meta.mainProgram} \
        --bash <("$out"/bin/${finalAttrs.meta.mainProgram} completion bash) \
        --fish <("$out"/bin/${finalAttrs.meta.mainProgram} completion fish) \
        --zsh  <("$out"/bin/${finalAttrs.meta.mainProgram} completion zsh)
    '';

    meta = {
      mainProgram = "determinate-nixd";
      description = "Daemon that makes your experience of installing and using Nix dramatically more smooth";
      homepage = "https://docs.determinate.systems/determinate-nix";
      license = {fullName = "Unfree";};
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      platforms = lib.attrNames hashes;
    };
  })
