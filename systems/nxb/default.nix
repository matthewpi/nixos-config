{
  configurationRevision,
  inputs,
  lib,
  outputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.framework-16-7040-amd

    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager

    outputs.nixosModules.desktop
    outputs.nixosModules.determinate
    outputs.nixosModules.hyprland
    outputs.nixosModules.persistence
    outputs.nixosModules.podman
    outputs.nixosModules.secureboot
    outputs.nixosModules.system
    outputs.nixosModules.tailscale

    ../../builders
    ../../users

    ./captive.nix
    ./disko.nix
    ./hardware-configuration.nix
  ];

  system = {
    inherit configurationRevision;
    stateVersion = "24.11";
  };

  nixpkgs = {
    config = lib.mkForce {};
    pkgs = outputs.lib.mkNixpkgs "x86_64-linux";
    hostPlatform = "x86_64-linux";
  };

  # agenix
  age.identityPaths = ["/persist/etc/ssh/ssh_host_ed25519_key"];
  age.secrets = {
    passwordfile-matthew.file = ../../secrets/passwordfile-matthew.age;
    desktop-resolved = {
      file = ../../secrets/desktop-resolved.age;
      path = "/etc/systemd/resolved.conf";
      mode = "444";
      owner = "root";
      group = "root";
    };
  };

  # Hostname and networking
  networking.hostName = "nxb";
  networking.wireless.iwd = {
    enable = true;
    settings = {
      Network = {
        EnableIPv6 = true;
        RoutePriorityOffset = 300;
      };
      Settings = {
        AutoConnect = true;
      };
    };
  };

  # Enable fwupd.
  services.fwupd = {
    enable = true;
    # Framework's firmware is in lvfs-testing, so enable it.
    extraRemotes = ["lvfs-testing"];
  };

  # Allow runtime reconfiguration of the timezone, defaulting to UTC if unset.
  time.timeZone = null;

  # Use the stable xanmod kernel.
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  # Disable SSH
  services.openssh = {
    enable = true;
    startWhenNeeded = true;
  };

  # Enable Tailscale
  services.tailscale = {
    enable = true;
    permitCertUid = "1000";
  };
  # networking.firewall.trustedInterfaces = ["tailscale0"];

  # Allow passwordless sudo
  security.sudo.extraRules = [
    {
      groups = ["wheel"];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  nix.settings.system-features = [
    "gccarch-x86-64-v2"
    "gccarch-x86-64-v3"
    "gccarch-x86-64-v4"
    "gccarch-znver3"
    "gccarch-znver4"
  ];

  # Allow loading of kernel modules at runtime.
  security.lockKernelModules = false;

  # Disable default resolved config, we use an age encrypted one with NextDNS.
  environment.etc."systemd/resolved.conf".enable = false;

  # Disable fstrim since we use btrfs async discard.
  services.fstrim.enable = false;

  # Enable the community built framework kernel module.
  hardware.framework.enableKmod = true;

  environment.systemPackages = with pkgs; [brightnessctl easyeffects];
  programs.corectrl.enable = false;
  services.ratbagd.enable = false;

  boot.kernelParams = [
    # https://wiki.nixos.org/wiki/Hardware/Framework/Laptop_16#Fix_Color_accuracy_in_Power_Saving_modes
    "amdgpu.abmlevel=0"
  ];

  # kind
  # networking.nameservers = ["1.1.1.1" "1.0.0.1"];

  # Use geoclue as the location provider.
  location.provider = "geoclue2";
  services.geoclue2 = {
    enableNmea = false;
    geoProviderUrl = "https://api.beacondb.net/v1/geolocate";
    submissionUrl = "https://api.beacondb.net/v2/geosubmit";
  };

  # Enable automatic-timezoned to automatically set the timezone according to geoclue.
  services.automatic-timezoned.enable = true;
  systemd.services.automatic-timezoned.environment.AUTOTZD_LOG_LEVEL = "debug";

  # Enable XWayland.
  programs.xwayland.enable = true;
}
