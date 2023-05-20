{
  config,
  lib,
  pkgs,
  ...
}: {
  # Enable libvirtd
  virtualisation.libvirtd = {
    enable = lib.mkDefault true;
    onBoot = lib.mkDefault "ignore";
    onShutdown = lib.mkDefault "shutdown";

    qemu = {
      ovmf = {
        packages = [
          # Compile OVMF without CSM support, it break secureboot for VMs
          (pkgs.OVMF.override {
            secureBoot = true;
            csmSupport = false;
            httpSupport = true;
            tpmSupport = true;
          })
          .fd
        ];
      };

      swtpm = {
        enable = lib.mkDefault true;
      };
    };
  };

  # Enable ip forwarding to allow DHCP to the VM
  boot.kernel.sysctl = lib.mkIf config.virtualisation.libvirtd.enable {
    "net.ipv4.conf.all.forwarding" = lib.mkForce true;
    "net.ipv6.conf.all.forwarding" = lib.mkForce true;
  };

  networking.firewall = lib.mkIf config.virtualisation.libvirtd.enable {
    # Trust the bridge network interface
    trustedInterfaces = ["virbr0"];

    # Needed for host <-> vm communication
    checkReversePath = lib.mkForce false;
  };
}
