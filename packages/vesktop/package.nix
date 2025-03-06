{
  electron,
  inputs,
  pnpm_9,
  replaceVars,
  vencord,
  vesktop,
}:
(vesktop.override {
  inherit electron;
  withTTS = false;
})
.overrideAttrs (oldAttrs: rec {
  patches = [
    ./0001-chore-enable-electron-options-for-better-hardware-ac.patch
    ./0003-chore-increase-screensharing-bitrate.patch
    ./0004-fix-ignore-errors-related-to-read-only-config-files.patch
    ./0005-chore-disable-update-checking.patch
    (replaceVars "${inputs.nixpkgs}/pkgs/by-name/ve/vesktop/use_system_vencord.patch" {
      inherit vencord;
    })
  ];

  pnpmDeps = pnpm_9.fetchDeps {
    inherit (oldAttrs) pname version src;
    inherit patches;
    hash = "sha256-xn3yE2S6hfCijV+Edx3PYgGro8eF76/GqarOIRj9Tbg=";
  };
})
