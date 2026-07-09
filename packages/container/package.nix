{
  fetchurl,
  installShellFiles,
  lib,
  libarchive,
  makeWrapper,
  stdenvNoCC,
  xar,
  versionCheckHook,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "container";
  version = "1.1.0";

  src = fetchurl {
    url = "https://github.com/apple/container/releases/download/${finalAttrs.version}/container-${finalAttrs.version}-installer-signed.pkg";
    hash = "sha256-DKHEKiJpwlV++x2CsbOKxVPmo6PaGxF5xDm87h59ZxQ=";
  };

  nativeBuildInputs = [
    installShellFiles
    libarchive
    makeWrapper
    xar
  ];

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    xar -xf "$src" Payload
    bsdtar --extract --file Payload --directory "$out"

    # Remove the update and uninstall scripts since they are useless if
    # container was installed with Nix.
    rm "$out"/bin/update-container.sh "$out"/bin/uninstall-container.sh

    runHook postInstall
  '';

  postInstall = lib.optionalString (stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform) ''
    installShellCompletion --cmd ${finalAttrs.meta.mainProgram} \
      --bash <("$out"/bin/${finalAttrs.meta.mainProgram} --generate-completion-script bash) \
      --fish <("$out"/bin/${finalAttrs.meta.mainProgram} --generate-completion-script fish) \
      --zsh  <("$out"/bin/${finalAttrs.meta.mainProgram} --generate-completion-script zsh)
  '';

  postFixup = ''
    wrapProgram "$out"/bin/container --set-default CONTAINER_INSTALL_ROOT "$out"
    wrapProgram "$out"/bin/container-apiserver --set-default CONTAINER_INSTALL_ROOT "$out"
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [versionCheckHook];

  meta = {
    mainProgram = "container";
    description = "Create and run Linux containers using lightweight virtual machines on a Mac";
    homepage = "https://github.com/apple/container";
    changelog = "https://github.com/apple/container/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [matthewpi];
    sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    platforms = ["aarch64-darwin"];
  };
})
