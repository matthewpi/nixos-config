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
  # Configure luks
  boot.initrd.luks.devices.root = {
    allowDiscards = true;
    bypassWorkqueues = true;
    crypttabExtraOpts = ["tpm2-device=auto"];
    device = luksDevice;
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
}
