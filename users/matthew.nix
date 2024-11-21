{
  config,
  isDesktop,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./matthew/impermanence.nix
  ];

  # Configure matthew with home-manager.
  home-manager.users = {
    matthew = import ./matthew/linux.nix;
  };

  # Enable flipperzero udev rules
  hardware.flipperzero.enable = true;

  # Enable ledger udev rules
  hardware.ledger.enable = true;

  # Enable steam udev rules
  hardware.steam-hardware.enable = isDesktop;

  # Enable zsh
  programs.zsh = {
    enable = true;
    vteIntegration = true;
  };

  # Allow matthew access to 1Password
  programs._1password-gui.polkitPolicyOwners = ["matthew"];

  # Enable yubikey-agent
  # Temporarily disabled due to breaking things.
  #services.yubikey-agent.enable = true;
  #systemd.user.services."yubikey-agent".serviceConfig.Slice = "background.slice";
  programs.gnupg.agent.pinentryPackage = with pkgs; pinentry-gnome3;
  environment.extraInit = let
    sshAuthSock =
      if pkgs.stdenv.isDarwin
      then "/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
      else "/.1password/agent.sock";
  in ''
    if [ -z "$SSH_AUTH_SOCK" -a -n "$HOME" ]; then
      export SSH_AUTH_SOCK="''${HOME}${sshAuthSock}"
    fi
  '';

  # Enable the wireshark dumpcap security wrapper.
  # This allows us to call dumpcap without using separate privilege escalation.
  programs.wireshark.enable = true;

  # Configure gamescope.
  programs.gamescope = {
    enable = isDesktop;
    capSysNice = true;
  };

  # Configure steam.
  programs.steam = {
    enable = isDesktop;
    package = pkgs.steam.override {
      extraEnv = {
        # Manually set SDL_VIDEODRIVER to x11.
        #
        # This fixes the `gldriverquery` segfault and issues with EAC crashing on games like Rust,
        # rather than gracefully disabling itself.
        SDL_VIDEODRIVER = "x11";
      };

      extraPkgs = pkgs:
        with pkgs; [
          xorg.libXcursor
          xorg.libXi
          xorg.libXinerama
          xorg.libXScrnSaver
          libpng
          libpulseaudio
          libvorbis
          stdenv.cc.cc.lib
          libkrb5
          keyutils
        ];
    };
    extraCompatPackages = with pkgs; [proton-ge-bin];
    extraPackages = with pkgs; [gamescope];
    localNetworkGameTransfers.openFirewall = true;
    protontricks.enable = true;
  };

  # Configure the matthew user.
  users.users.matthew = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups =
      ["wheel" "audio" "video" "systemd-journal"]
      ++ lib.optionals config.programs.corectrl.enable ["corectrl"]
      ++ lib.optionals config.programs.wireshark.enable ["wireshark"]
      ++ lib.optionals config.networking.networkmanager.enable ["networkmanager"]
      ++ lib.optionals config.virtualisation.libvirtd.enable ["libvirtd" "qemu-libvirtd"]
      ++ lib.optionals config.systemd.network.enable ["systemd-network"]
      ++ lib.optionals config.services.resolved.enable ["systemd-resolve"];
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAJ30VI7vAdrs2MDgkNHSQMJt2xBtBLrirVhinSyteeU"];
    hashedPasswordFile = config.age.secrets.passwordfile-matthew.path;
  };
}
