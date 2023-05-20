{lib, ...}: {
  # Enable bluetooth but don't start it automatically on boot
  hardware.bluetooth = {
    enable = lib.mkDefault true;
    powerOnBoot = lib.mkDefault false;
  };
}
