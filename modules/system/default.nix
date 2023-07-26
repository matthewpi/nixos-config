{
  flake.nixosModules.system = {lib, ...}: {
    imports = [
      ./dbus.nix
      ./irqbalance.nix
      ./networking.nix
      ./nix.nix
      ./openssh.nix
      ./security.nix
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
  };
}
