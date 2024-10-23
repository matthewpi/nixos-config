{
  boot.kernelModules = ["kvm-amd"];

  boot.initrd.availableKernelModules = ["ahci" "nvme" "usbhid" "xhci_pci"];
  boot.initrd.supportedFilesystems = ["btrfs"];

  # Change the boot loader timeout to 3 seconds.
  boot.loader.timeout = 3;

  # Use systemd stage 1
  boot.initrd.systemd.enable = true;

  # Enable graphics.
  hardware.graphics.enable = true;
}
