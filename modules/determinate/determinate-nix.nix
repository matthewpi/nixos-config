{
  fetchFromGitHub,
  generateSplicesForMkScope,
  lib,
  newScope,
  pkgs,
  splicePackages,
  stdenv,
}: let
  src = fetchFromGitHub {
    owner = "DeterminateSystems";
    repo = "nix-src";
    tag = "v3.15.2";
    hash = "sha256-32oMe1y+kwvIJNiJsIvozTuSmDxcwST06i+0ak+L4AU=";
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

  determinate-nix = determinate_nixComponents.nix-everything;
in
  determinate-nix
