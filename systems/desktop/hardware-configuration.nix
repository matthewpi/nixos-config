{
  config,
  lib,
  pkgs,
  ...
}: let
  bootDevice = "/dev/disk/by-uuid/2730-83BE";
  luksDevice = "/dev/disk/by-uuid/109a3b96-3ca2-4ac2-a1d3-2d01085e6ff8";
  rootDevice = "/dev/disk/by-uuid/cd9c640c-dd1b-42b4-80fa-95a6f8b739d7";
in {
  boot.kernelModules = ["kvm-amd"];

  boot.initrd.availableKernelModules = ["ahci" "nvme" "usbhid" "xhci_pci"];
  boot.initrd.supportedFilesystems = ["btrfs"];

  # Change the boot loader timeout to 15 seconds.
  boot.loader.timeout = 15;

  # Use systemd stage 1
  boot.initrd.systemd.enable = true;

  # Configure luks
  boot.initrd.luks.devices = {
    root = {
      allowDiscards = true;
      bypassWorkqueues = true;

      crypttabExtraOpts = [
        "tpm2-device=auto"
      ];

      device = luksDevice;
    };
  };

  fileSystems = {
    "/boot" = {
      device = bootDevice;
      fsType = "vfat";
    };

    "/" = {
      device = rootDevice;
      fsType = "btrfs";
      options = ["subvol=root" "compress=no" "noatime" "nodev" "noexec" "nosuid" "discard=async"];
    };

    "/tmp" = {
      device = rootDevice;
      fsType = "btrfs";
      options = ["subvol=tmp" "compress=no" "noatime" "nodev" "nosuid" "discard=async"];
    };

    "/nix" = {
      device = rootDevice;
      fsType = "btrfs";
      options = ["subvol=nix" "compress=no" "noatime" "nodev" "nosuid" "discard=async"];
    };

    "/persist" = {
      device = rootDevice;
      fsType = "btrfs";
      options = ["subvol=persist" "compress=no" "noatime" "nodev" "noexec" "nosuid" "discard=async"];
      neededForBoot = true;
    };

    "/persist/home" = {
      device = rootDevice;
      fsType = "btrfs";
      options = ["subvol=home" "compress=no" "noatime" "nodev" "nosuid" "discard=async"];
      neededForBoot = true;
    };

    "/var/log" = {
      device = rootDevice;
      fsType = "btrfs";
      options = ["subvol=log" "compress=zstd" "noatime" "nodev" "noexec" "nosuid" "discard=async"];
      neededForBoot = true;
    };
  };

  swapDevices = [];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.opengl.enable = true;

  # Add a udev rule for Elgato Stream Deck(s)
  # Add a udev rule to set the DPI on a Logitech MX Master 3
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0060|0063|006c|006d", MODE="0660", TAG+="systemd", SYMLINK+="streamdeck"

    ACTION=="change", SUBSYSTEM=="power_supply", ATTR{online}=="1", ATTR{manufacturer}=="Logitech", ATTR{model_name}=="Wireless Mouse MX Master 3", RUN+="${pkgs.libratbag}/bin/ratbagctl 'Logitech MX Master 3' dpi set 400"
  '';
}
