{
  flavour,
  lib,
  inputs,
  outputs,
  pkgs,
  ...
}: {
  system.stateVersion = 4;
  nixpkgs.hostPlatform = "x86_64-darwin";

  # Configure home-manager
  home-manager = {
    useUserPackages = true;

    extraSpecialArgs = {
      inherit flavour inputs outputs;
    };

    users = {
      matthew = import ../../users/matthew/darwin.nix;
    };
  };

  # Enable nix-daemon
  services.nix-daemon.enable = true;

  # Enable zsh
  programs.zsh.enable = true;

  # Fonts
  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      go-font
      hack-font
      jetbrains-mono
      (nerdfonts.override {
        fonts = ["Go-Mono" "Hack" "JetBrainsMono"];
      })
    ];
  };

  # Configure users
  users.users.matthew = {
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAJ30VI7vAdrs2MDgkNHSQMJt2xBtBLrirVhinSyteeU"];
    home = "/Users/matthew";
  };

  nix = {
    # Use the latest version of Nix
    package = pkgs.nixVersions.nix_2_15;

    settings = {
      build-users-group = "nixbld";

      # Auto-scale builders
      max-jobs = lib.mkDefault "auto";
      cores = lib.mkDefault 0;

      # Use sandboxed builds
      sandbox = lib.mkDefault true;
      sandbox-fallback = lib.mkDefault false;
      # extra-sandbox-paths = lib.mkDefault [];

      # Substituters
      substituters = lib.mkDefault [];
      trusted-substituters = lib.mkDefault [];
      trusted-public-keys = lib.mkDefault [];

      # Hard-link files by file content address
      # Disabled on darwin due to https://github.com/NixOS/nix/issues/7273
      auto-optimise-store = lib.mkDefault (! pkgs.stdenv.isDarwin);

      # Basic trust settings
      require-sigs = lib.mkDefault true;
      trusted-users = lib.mkDefault ["root" "matthew"];
      allowed-users = lib.mkDefault ["root" "matthew" "@wheel"];

      # Expose functionality
      system-features = lib.mkDefault ["benchmark" "big-parallel" "kvm" "nixos-test"];

      # Enable experimental features
      experimental-features = lib.mkDefault ["nix-command" "flakes"];
    };
  };
}
