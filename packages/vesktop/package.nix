{
  fetchFromGitHub,
  pnpm_9,
  vesktop,
}:
vesktop.overrideAttrs (oldAttrs: rec {
  version = "1.5.4";

  src = fetchFromGitHub {
    owner = "Vencord";
    repo = "Vesktop";
    rev = "refs/tags/v${version}";
    hash = "sha256-zvyDKgNTRha7Z7KGAA7x9LRJrL+1zyb5TZEFFK8Ffrc=";
  };

  pnpmDeps = pnpm_9.fetchDeps {
    inherit (oldAttrs) pname;
    inherit version src patches;
    hash = "sha256-GSAOdvd8X4dQNTDZMnzc4oMY54TKvdPuAOMb6DRzCEM=";
  };

  patches = [
    ./0001-chore-enable-electron-options-for-better-hardware-de.patch
    ./0002-chore-enable-electron-options-for-better-hardware-ac.patch
    ./0003-chore-increase-screensharing-bitrate.patch
    ./0004-fix-ignore-errors-related-to-read-only-config-files.patch
    ./0005-chore-disable-update-checking.patch
  ];
})
