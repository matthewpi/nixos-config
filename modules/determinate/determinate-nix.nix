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
      tag = "v3.17.2";
      hash = "sha256-5pg3HyPEUj/AXXwOQAwyieyDx0c1/1rf7+EsOCa1rJM=";
    };
    patches = [
      ./patches/0001-wasmtime-disable-checks-unpin-rustPlatform-version.patch
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

  determinate-nix = determinate_nixComponents.nix-everything;
in
  determinate-nix
  // {
    passthru.nix-eval-jobs = nix-eval-jobs;
  }
