{
  fetchzip,
  lib,
  stdenvNoCC,
  # Can be overridden to alter the display name in steam
  # This could be useful if multiple versions should be installed together
  steamDisplayName ? "GE-Proton",
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "proton-ge-bin";
  version = "GE-Proton10-31";

  src = fetchzip {
    url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${finalAttrs.version}/${finalAttrs.version}.tar.gz";
    hash = "sha256-mfbbTm5gXWvdJ4fb/pfJ4E+FHpqeqmuVi40KfubagBs=";
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  outputs = ["out" "steamcompattool"];

  installPhase = ''
    runHook preInstall

    # Make it impossible to add to an environment. You should use the appropriate NixOS option.
    # Also leave some breadcrumbs in the file.
    echo 'proton-ge-bin should not be installed into environments. Please use programs.steam.extraCompatPackages instead.' > "$out"

    mkdir "$steamcompattool"
    ln -s "$src"/* "$steamcompattool"
    rm $steamcompattool/compatibilitytool.vdf
    cp "$src"/compatibilitytool.vdf "$steamcompattool"

    runHook postInstall
  '';

  preFixup = ''
    substituteInPlace "$steamcompattool"/compatibilitytool.vdf \
      --replace-fail '${finalAttrs.version}' '${steamDisplayName}'
  '';

  meta = {
    description = ''
      Compatibility tool for Steam Play based on Wine and additional components.

      (This is intended for use in the `programs.steam.extraCompatPackages` option only.)
    '';
    homepage = "https://github.com/GloriousEggroll/proton-ge-custom";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [matthewpi];
    platforms = ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
})
