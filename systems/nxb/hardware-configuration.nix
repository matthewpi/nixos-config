{
  boot.initrd.systemIdentity.pcr15 = "f6e2bdf7bf88a83988598a4f4dad7de3f9d144a6ac8c8f9413962eb034ed1c21";

  boot.kernelModules = ["kvm-amd"];
  boot.initrd.availableKernelModules = ["ahci" "nvme" "usbhid" "xhci_pci"];
  boot.initrd.supportedFilesystems = ["btrfs"];

  # Change the boot loader timeout to 3 seconds.
  boot.loader.timeout = 3;

  # Use systemd stage 1.
  boot.initrd.systemd.enable = true;
}
