{inputs, ...}: {
  # Force nix to use the local flake-registry to prevent it from being downloaded.
  nix.settings.flake-registry = "/etc/nix/registry.json";

  # Pin nixpkgs in the registry.
  nix.registry.nixpkgs.to = {
    type = "path";
    path = inputs.nixpkgs;
    inherit (inputs.nixpkgs) narHash;
  };

  # Pin darwin in the registry.
  nix.registry.darwin.to = {
    type = "path";
    path = inputs.darwin;
    inherit (inputs.darwin) narHash;
  };
}
