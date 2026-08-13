{
  fetchurl,
  lib,
  stdenvNoCC,
  versionCheckHook,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "socktainer";
  version = "1.2.1";

  src = fetchurl {
    url = "https://github.com/socktainer/socktainer/releases/download/v${finalAttrs.version}/socktainer";
    hash = "sha256-AcHX3dS+KwPljWa8eSIvwaqQE474hyRmJaLIITsO0KE=";
    executable = true;
  };

  dontUnpack = true;
  dontBuild = true;
  # Binary is notarized, don't modify it.
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"/bin
    ln -s "$src" "$out"/bin/${finalAttrs.meta.mainProgram}

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [versionCheckHook];

  meta = {
    mainProgram = "socktainer";
    description = "Docker REST API for Apple Containers";
    homepage = "https://socktainer.github.io/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [matthewpi];
    sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    platforms = ["aarch64-darwin"];
  };
})
