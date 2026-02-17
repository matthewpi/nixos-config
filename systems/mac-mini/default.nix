{
  config,
  configurationRevision,
  inputs,
  lib,
  outputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.home-manager.darwinModules.home-manager

    ./builders
    ./flake-registry.nix
    ./nix-module.nix
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

  # Install packages for the entire system.
  environment.systemPackages = with pkgs; [
    coreutils-full
    git
    openssh
    ghostty-bin.terminfo
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
    # Normally I'd just use the macOS bundled zsh shell, but it seems to have
    # some issues with Ghostty when I SSH into the system.
    shell = pkgs.zsh;
  };

  users.knownGroups = ["builder" "_builder"];
  users.knownUsers = ["builder" "_builder"];
  users.users._builder = {
    uid = 399;
    gid = config.users.groups._builder.gid;
    home = "/var/lib/builder";
    name = "_builder";
    createHome = true;
    shell = pkgs.zsh;
    description = "System user for the Nix Remote Builds";
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFG+u6aKoyIjAXRRkRWreEVrUP/Pcubf8U0gSn/gW1gC"];
  };
  users.groups._builder = {
    gid = 32001;
    name = "_builder";
    description = "System group for Nix Remote Builds";
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
  };

  # Configure matthew with home-manager.
  home-manager.users.matthew = {config, ...}: {
    imports = [
      ../../users/matthew/catppuccin.nix

      ../../users/matthew/cli/atuin.nix
      ../../users/matthew/cli/bat.nix
      ../../users/matthew/cli/bottom.nix
      ../../users/matthew/cli/direnv.nix
      ../../users/matthew/cli/eza.nix
      ../../users/matthew/cli/fzf.nix
      ../../users/matthew/cli/gh.nix
      ../../users/matthew/cli/git.nix
      ../../users/matthew/cli/kubernetes.nix
      ../../users/matthew/cli/man.nix
      ../../users/matthew/cli/neovim.nix
      ../../users/matthew/cli/nix-index.nix
      ../../users/matthew/cli/nodejs.nix
      ../../users/matthew/cli/ripgrep.nix
      ../../users/matthew/cli/ssh.nix
      ../../users/matthew/cli/starship.nix
      ../../users/matthew/cli/tmux.nix
      ../../users/matthew/cli/zsh.nix

      ../../users/matthew/desktop/applications/terminal.nix
      ../../users/matthew/desktop/applications/zed-editor.nix
    ];

    home = {
      stateVersion = "26.05";

      homeDirectory = "/Users/${config.home.username}";
      username = "matthew";

      preferXdgDirectories = true;
    };

    home.sessionVariables.XDG_STATE_HOME = "${config.home.homeDirectory}/.local/state";

    # Enable home-manager.
    programs.home-manager.enable = true;
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

    # Reset TERM with new TERMINFO available (if any)
    export TERM=$TERM
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
  ];

  environment.pathsToLink = [
    "/share/terminfo"
  ];

  environment.etc.terminfo.source = "${config.system.path}/share/terminfo";

  # TODO: use `environment.profileRelativeSessionVariables`
  environment.variables = {
    TERMINFO_DIRS = map (path: path + "/share/terminfo") config.environment.profiles ++ ["/usr/share/terminfo"];
  };

  security = let
    extraConfig = ''

      # Keep terminfo database for root and %admin.
      Defaults:root,%admin env_keep+=TERMINFO_DIRS
      Defaults:root,%admin env_keep+=TERMINFO
    '';
  in
    lib.mkIf config.security.sudo.keepTerminfo {
      sudo = {inherit extraConfig;};
    };
}
