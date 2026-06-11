{
  applyPatches,
  callPackage,
  fetchFromGitHub,
  generateSplicesForMkScope,
  lib,
  newScope,
  pkgs,
  splicePackages,
  stdenv,
}: let
  src = applyPatches {
    src = fetchFromGitHub {
      owner = "DeterminateSystems";
      repo = "nix-src";
      tag = "v3.21.1";
      hash = "sha256-/JuW5C6sWuC836Y9b7hga3ZvhRiY4k4Zs73RRg5KVWM=";
    };
    patches = [
      ./patches/0001-wasmtime-disable-checks.patch
      # ./patches/0002-libblake3-ensure-useTBB-remains-disabled.patch
    ];
  };

  determinate_nixDependencies =
    lib.makeScopeWithSplicing'
    {
      inherit splicePackages newScope;
    }
    {
      otherSplices = generateSplicesForMkScope "determinate_nixDependencies";
      f = import "${src}/packaging/dependencies.nix" {
        # Inputs is required but is unused.
        inputs = null;
        inherit stdenv pkgs;
      };
    };

  determinate_nixComponents =
    lib.makeScopeWithSplicing'
    {
      inherit splicePackages;
      inherit (determinate_nixDependencies) newScope;
    }
    {
      otherSplices = generateSplicesForMkScope "determinate_nixComponents";
      f = import "${src}/packaging/components.nix" {
        inherit src lib pkgs;
        officialRelease = true;
        maintainers = [];
      };
    };

  nix-eval-jobs = callPackage ./nix-eval-jobs.nix {nixComponents = determinate_nixComponents;};

  determinate-nix = determinate_nixComponents.nix-everything.overrideAttrs {doCheck = false;};
in
  determinate-nix
  // {
    passthru.nix-eval-jobs = nix-eval-jobs;
  }
