{pkgs, ...}: {
  # bootspec
  boot.bootspec.enable = true;

  # EFI
  boot.loader.efi.canTouchEfiVariables = true;

  # systemd-boot
  boot.loader.systemd-boot.configurationLimit = 5;

  # Secure Boot
  boot.loader.secureboot = {
    enable = true;
    signingKeyPath = "/etc/secureboot/keys/db/db.key";
    signingCertPath = "/etc/secureboot/keys/db/db.pem";
  };

  # Add tpm and fido2 packages for auto-unlock.
  environment.systemPackages = with pkgs; [libfido2 tpm2-tools tpm2-tss];
  boot.initrd.availableKernelModules = ["tpm-tis" "tpm-crb"];
}
