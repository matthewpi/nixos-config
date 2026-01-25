{
  fetchurl,
  installShellFiles,
  lib,
  stdenvNoCC,
}: let
  hashes = {
    x86_64-linux = "sha256-anMErEzlxo/slr5/Hm7Gg0wT70+zoaA+aIHH0+CMgZY=";
  };

  system = stdenvNoCC.hostPlatform.system;
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "determinate-nixd";
    version = "3.15.2";

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
