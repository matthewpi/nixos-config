{
  lib,
  pkgs,
  ...
}: {
  nix = {
    # Use the latest version of Nix
    package = pkgs.nixVersions.nix_2_19;

    settings = {
      # Auto-scale builders
      max-jobs = lib.mkDefault "auto";
      cores = lib.mkDefault 0;

      # Use sandboxed builds
      sandbox = lib.mkDefault true;
      sandbox-fallback = lib.mkDefault false;
      extra-sandbox-paths = lib.mkDefault [];

      # Substituters
      substituters = lib.mkDefault [];
      trusted-substituters = lib.mkDefault [];
      trusted-public-keys = lib.mkDefault [];

      # Hard-link files by file content address
      # Disabled on darwin due to https://github.com/NixOS/nix/issues/7273
      auto-optimise-store = lib.mkDefault (!pkgs.stdenv.isDarwin);

      # Basic trust settings
      require-sigs = lib.mkDefault true;
      trusted-users = lib.mkDefault ["root" "@wheel"];
      allowed-users = lib.mkDefault ["root" "@wheel"];

      # Expose functionality
      system-features = lib.mkDefault ["benchmark" "big-parallel" "kvm" "nixos-test" "uid-range"];

      # Enable experimental features
      experimental-features = lib.mkDefault ["auto-allocate-uids" "cgroups" "nix-command" "flakes"];
      auto-allocate-uids = lib.mkDefault true;
      use-cgroups = lib.mkDefault true;
      accept-flake-config = lib.mkDefault true;

      # Configure Nix to follow the XDG base directory spec.
      use-xdg-base-directories = lib.mkDefault true;

      # Don't warn on a dirty tree.
      warn-dirty = lib.mkDefault false;

      # Increase the amount of lines logged immediately following a build failure.
      log-lines = lib.mkDefault 25;
    };
  };
}
