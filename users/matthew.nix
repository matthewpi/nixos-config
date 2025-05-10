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

  # Configure the matthew user.
  users.users.matthew = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups =
      ["wheel" "audio" "video" "systemd-journal"]
      ++ lib.optional config.programs.corectrl.enable "corectrl"
      ++ lib.optional config.programs.wireshark.enable "wireshark"
      ++ lib.optional config.networking.networkmanager.enable "networkmanager"
      ++ lib.optionals config.virtualisation.libvirtd.enable ["libvirtd" "qemu-libvirtd"]
      ++ lib.optional config.systemd.network.enable "systemd-network"
      ++ lib.optional config.services.resolved.enable "systemd-resolve"
      ++ lib.optional config.virtualisation.podman.enable "podman";
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAJ30VI7vAdrs2MDgkNHSQMJt2xBtBLrirVhinSyteeU"];
    hashedPasswordFile = config.age.secrets.passwordfile-matthew.path;
  };

  # Enable flipperzero udev rules
  hardware.flipperzero.enable = true;

  # Enable ledger udev rules
  hardware.ledger.enable = true;

  # Enable steam udev rules
  hardware.steam-hardware.enable = isDesktop;

  # Allow non-root access to QMK keyboards.
  hardware.keyboard.qmk.enable = true;

  # Enable zsh
  programs.zsh = {
    enable = true;
    vteIntegration = true;
  };

  # Allow matthew access to 1Password.
  programs._1password-gui.polkitPolicyOwners = ["matthew"];

  # Configure SSH to use 1Password SSH Agent.
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

  # Configure steam.
  programs.steam = {
    enable = isDesktop;
    package = pkgs.steam.override {
      extraEnv = {
        # Manually set SDL_VIDEODRIVER to x11.
        #
        # This fixes the `gldriverquery` segfault and issues with EAC crashing
        # on games like Rust, rather than gracefully disabling itself.
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
          (lib.getLib stdenv.cc.cc)
          libkrb5
          keyutils
        ];
    };
    extraCompatPackages = with pkgs; [proton-ge-bin];
    localNetworkGameTransfers.openFirewall = true;
    protontricks.enable = true;
  };

  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
  };

  boot.kernelModules = lib.optional isDesktop "ntsync";

  services.udev.extraRules = lib.mkIf isDesktop ''
    # Allow all users to access ntsync.
    KERNEL=="ntsync", MODE="0644"

    # Set the "uaccess" tag for raw HID access for VKB Devices in wine
    KERNEL=="hidraw*", ATTRS{idVendor}=="231d", ATTRS{idProduct}=="*", MODE="0660", TAG+="uaccess"
  '';
}
