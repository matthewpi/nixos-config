{
  flake.nixosModules.system = {lib, ...}: {
    imports = [
      ./dbus.nix
      ./flake-registry.nix
      ./networking.nix
      ./nix-daemon.nix
      ./openssh.nix
      ./security.nix
      ./well-known-hosts.nix
      ./zram.nix
    ];

    # Enable redistributable firmware
    hardware.enableRedistributableFirmware = lib.mkDefault true;

    # Cleaning /tmp on boot
    boot.tmp.cleanOnBoot = lib.mkDefault true;

    # Set the default timezone to UTC
    time.timeZone = lib.mkDefault "Etc/UTC";

    # Set the default locale to en_CA
    i18n.defaultLocale = lib.mkDefault "en_CA.UTF-8";

    # Enable polkit
    security.polkit.enable = lib.mkDefault true;

    # Enable htop
    programs.htop.enable = lib.mkDefault true;

    # Enable `systemd-oomd` on more slices for better OOM management.
    systemd.oomd = {
      enableRootSlice = lib.mkDefault true;
      enableSystemSlice = lib.mkDefault true;
      enableUserSlices = lib.mkDefault true;
    };

    # Configure nh, a Nix CLI helper.
    # ref; https://github.com/nix-community/nh
    programs.nh = {
      enable = lib.mkDefault true;
      clean.enable = lib.mkDefault true;
      clean.extraArgs = lib.mkDefault "--keep-since 5d --keep 5";
      flake = lib.mkDefault "/code/matthewpi/nixos-config";
    };
  };
}
