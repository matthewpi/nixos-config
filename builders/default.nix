{lib, ...}: {
  imports = [
    ./blahaj.nix
    ./djt.nix
  ];

  # Enable distributed builds.
  nix.distributedBuilds = true;

  # Useful when the builder has a faster internet connection than yours
  nix.settings.builders-use-substitutes = true;

  # Override the default substituters.
  nix.settings.substituters = lib.mkForce [
    "https://ncps.blahaj.systems" # local cache for cache.nixos.org
    "https://cache.blahaj.systems" # local builder via harmonia
  ];
}
