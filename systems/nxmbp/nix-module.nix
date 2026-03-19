{
  config,
  lib,
  ...
}: {
  environment.etc."nix/registry.json" = lib.mkIf (config.nix.registry != null) {
    text = builtins.toJSON {
      version = 2;
      flakes = lib.mapAttrsToList (_n: v: {inherit (v) from to exact;}) config.nix.registry;
    };
  };
}
