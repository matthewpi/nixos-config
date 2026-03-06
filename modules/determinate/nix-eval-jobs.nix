{
  boost,
  curl,
  fetchFromGitHub,
  lib,
  meson,
  ninja,
  nixComponents,
  nlohmann_json,
  pkg-config,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "nix-eval-jobs";
  version = "3.17.0";

  src = fetchFromGitHub {
    owner = "DeterminateSystems";
    repo = "nix-eval-jobs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TBInDAyOGMusJnbyTFq3YasO6DZp8Bdu46tkJn9a0m0=";
  };

  buildInputs = [
    boost
    curl
    nlohmann_json
    nixComponents.nix-store
    nixComponents.nix-fetchers
    nixComponents.nix-expr
    nixComponents.nix-flake
    nixComponents.nix-main
    nixComponents.nix-cmd
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  outputs = [
    "out"
    "dev"
  ];

  # Since this package is intimately tied to a specific Nix release, we
  # propagate the Nix used for building it to make it easier for users
  # downstream to reference it.
  passthru = {
    inherit nixComponents;
    # For nix-fast-build
    nix = nixComponents.nix-cli;
  };

  meta = {
    mainProgram = "nix-eval-jobs";
    description = "Hydra's builtin hydra-eval-jobs as a standalone";
    homepage = "https://github.com/nix-community/nix-eval-jobs";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [matthewpi];
    platforms = lib.platforms.unix;
  };
})
