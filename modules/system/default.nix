{
  flake.nixosModules.system = {
    inputs,
    lib,
    ...
  }: {
    imports = [
      ./dbus.nix
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

    # Pin nixpkgs in the registry. (affects flake commands)
    nix.registry.nixpkgs.to = {
      type = "path";
      path = inputs.nixpkgs;
      inherit (inputs.nixpkgs) narHash;
    };

    # Pre-fetch the flake-registry to prevent it from being re-downloaded.
    nix.settings.flake-registry = "${inputs.flake-registry}/flake-registry.json";
  };
}
