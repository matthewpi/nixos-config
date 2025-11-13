{
  inputs,
  installShellFiles,
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "determinate-nixd";
  version = "3.13.1";
  src = inputs."determinate-nixd-${stdenvNoCC.hostPlatform.system}";

  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [installShellFiles];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"/bin
    install -Dm755 "$src" "$out"/bin/${finalAttrs.meta.mainProgram}

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
    platforms = ["x86_64-linux"];
  };
})
