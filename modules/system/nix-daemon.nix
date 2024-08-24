{
  lib,
  pkgs,
  ...
}: {
  nix = {
    # Use the latest version of Nix
    package = pkgs.nixVersions.nix_2_24;

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
      trusted-users = ["root" "@wheel"];
      allowed-users = ["root" "@wheel"];

      # Enable experimental features
      experimental-features = [
        "auto-allocate-uids"
        "ca-derivations"
        "cgroups"
        "nix-command"
        "flakes"
      ];
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

  # Only use necessary profile paths.
  # TODO: this should be gated behind `use-xdg-base-directories`.
  # NOTE: some services (like flatpak) may try to add other entries to this array,
  # be careful when using this.
  environment.profiles = lib.mkForce [
    "\${XDG_STATE_HOME}/nix/profile"
    "/etc/profiles/per-user/$USER"
    "/run/current-system/sw"
  ];
}
