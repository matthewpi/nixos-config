{
  boot.initrd.systemIdentity.pcr15 = "ce573d6fcabb125bc170724af61424b1992dfeaf7e258591c343efb76bff4b0b";

  boot.kernelModules = ["kvm-amd"];
  boot.initrd.availableKernelModules = ["ahci" "nvme" "usbhid" "xhci_pci"];
  boot.initrd.supportedFilesystems = ["btrfs"];

  # Change the boot loader timeout to 3 seconds.
  boot.loader.timeout = 3;

  # Use systemd stage 1.
  boot.initrd.systemd.enable = true;
}
