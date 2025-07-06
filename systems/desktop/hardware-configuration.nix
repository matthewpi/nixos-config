{
  lib,
  pkgs,
  ...
}: {
  boot.initrd.systemIdentity.pcr15 = "";

  boot.kernelModules = ["kvm-amd"];
  boot.initrd.availableKernelModules = ["ahci" "nvme" "usbhid" "xhci_pci"];
  boot.initrd.supportedFilesystems = ["btrfs"]; # "ntfs"

  # Change the boot loader timeout to 3 seconds.
  boot.loader.timeout = 3;

  # Use systemd stage 1.
  boot.initrd.systemd.enable = true;

  # Add a udev rule for Elgato Stream Deck(s)
  # Add a udev rule to set the DPI on a Logitech MX Master 3
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0060|0063|006c|006d", MODE="0660", TAG+="systemd", SYMLINK+="streamdeck"

    ACTION=="change", SUBSYSTEM=="power_supply", ATTR{online}=="1", ATTR{manufacturer}=="Logitech", ATTR{model_name}=="Wireless Mouse MX Master 3", RUN+="${lib.getExe' pkgs.libratbag "ratbagctl"} 'Logitech MX Master 3' dpi set 400"
  '';

  # fileSystems."/mnt/games" = {
  #   device = "/dev/disk/by-uuid/CE3E37913E377197";
  #   fsType = "ntfs3";
  #   options = [
  #     "noatime"
  #     "nosuid"
  #     "nodev"
  #     "nofail"
  #     "x-gvfs-show"
  #     "uid=1000"
  #     "gid=1000"
  #     "rw"
  #     "user"
  #     "exec"
  #     "umask=000"
  #   ];
  # };
}
