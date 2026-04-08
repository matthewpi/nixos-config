{
  fetchurl,
  installShellFiles,
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "determinate-nixd";
  version = "3.17.3";
  src = finalAttrs.passthru.sources.${stdenvNoCC.hostPlatform.system} or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");

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

  passthru.sources = {
    aarch64-linux = fetchurl {
      url = "https://install.determinate.systems/determinate-nixd/tag/v${finalAttrs.version}/aarch64-linux";
      hash = "sha256-6N7AhYldtvvIQ6jFBDPK7lZHBVr/yFkyx+fgWvw3hoA=";
      executable = true;
    };
    x86_64-linux = fetchurl {
      url = "https://install.determinate.systems/determinate-nixd/tag/v${finalAttrs.version}/x86_64-linux";
      hash = "sha256-7mA8YjsUXcZadVXH3XgTms2KFTnjGPPt5FBADtPhzvA=";
      executable = true;
    };
  };

  meta = {
    mainProgram = "determinate-nixd";
    description = "Daemon that makes your experience of installing and using Nix dramatically more smooth";
    homepage = "https://docs.determinate.systems/determinate-nix";
    license = {fullName = "Unfree";};
    maintainers = with lib.maintainers; [matthewpi];
    sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    platforms = builtins.attrNames finalAttrs.passthru.sources;
  };
})
