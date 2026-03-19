{
  configurationRevision,
  inputs,
  lib,
  outputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.home-manager.darwinModules.home-manager

    ./flake-registry.nix
    ./nix-module.nix
    ./terminfo.nix
  ];

  nixpkgs = {
    config = lib.mkForce {};
    pkgs = outputs.lib.mkNixpkgs "aarch64-darwin";
    hostPlatform = "aarch64-darwin";
  };

  system = {
    inherit configurationRevision;

    # nix-darwin state version
    stateVersion = 6;
  };

  # System uses Determinate Nix, so don't enable Nix.
  nix.enable = false;

  # Enable ZSH.
  programs.zsh.enable = true;
  environment.shells = with pkgs; [zsh];

  # Install packages for the entire system.
  environment.systemPackages = with pkgs; [
    coreutils-full
    git
    openssh
  ];

  # Configure fonts.
  fonts.packages = with pkgs; [
    inter
    monaspace.otf
    monaspace.nerdfonts
  ];

  # Configure the matthew user.
  users.users.matthew = {
    home = "/Users/matthew";
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAJ30VI7vAdrs2MDgkNHSQMJt2xBtBLrirVhinSyteeU"];
    shell = pkgs.zsh;
  };

  # Configure home-manager
  home-manager = {
    # Use the `nixpkgs.pkgs` instance of nixpkgs and disable per-user `nixpkgs.*`
    # config options.
    #
    # This allows us to avoid having to construct multiple nixpkgs instances
    # and allow us to easily configure overlays and other settings (such as
    # allowUnfree) in one place rather than multiple.
    useGlobalPkgs = true;

    # Allow users to install their own packages.
    useUserPackages = true;

    extraSpecialArgs = {
      inherit inputs outputs;
      isDesktop = false;
    };

    # Configure matthew with home-manager.
    users.matthew = import ./users/matthew.nix;
  };

  # Configure SSH to use 1Password SSH Agent.
  environment.extraInit = let
    sshAuthSock = "/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
  in ''
    if [[ "$SSH_AUTH_SOCK" == '/private/tmp/'* ]]; then
      export SSH_AUTH_SOCK="''${HOME}${sshAuthSock}"
    fi

    if [ -z "$SSH_AUTH_SOCK" -a -n "$HOME" ]; then
      export SSH_AUTH_SOCK="''${HOME}${sshAuthSock}"
    fi
  '';

  environment.profiles = lib.mkForce [
    "/Users/$USER/.local/state/nix/profile"
    "/etc/profiles/per-user/$USER"
    "/run/current-system/sw"
  ];

  # TODO: no `lib.mkForce`?
  environment.systemPath = [
    "/etc/profiles/per-user/$USER/bin"
    "/run/current-system/sw/bin"
    "/nix/var/nix/profiles/default/bin"
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"

    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  environment.variables = {
    HOMEBREW_PREFIX = "/opt/homebrew";
    HOMEBREW_CELLAR = "/opt/homebrew/Cellar";
    HOMEBREW_REPOSITORY = "/opt/homebrew";
  };

  # Disable nh checking for `experimental-features` that are no longer
  # necessary since we use Determinate Nix.
  environment.variables.NH_NO_CHECKS = "1";
  environment.variables.NH_FLAKE = "/Users/matthew/Developer/matthewpi/nixos-config";
}
