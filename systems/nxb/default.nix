{
  config,
  pkgs,
  ...
}: {
  system.stateVersion = "24.11";

  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];

  # Allow unfree
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
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

  # Use my local timezone instead of UTC
  time.timeZone = "America/Edmonton";

  # Use the xanmod kernel.
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

  environment.systemPackages = with pkgs; [
    brightnessctl
    easyeffects
  ];

  programs.corectrl.enable = false;
  programs.gamemode.enable = false;
  services.ratbagd.enable = false;

  boot.kernelParams = [
    # https://wiki.nixos.org/wiki/Hardware/Framework/Laptop_16#Fix_Color_accuracy_in_Power_Saving_modes
    "amdgpu.abmlevel=0"
  ];
}
