{pkgs, ...}: {
  home.packages = with pkgs; [virt-manager];

  dconf.settings = {
    "org/virt-manager/virt-manager" = {
      xmleditor-enabled = true;
    };

    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };

    "org/virt-manager/virt-manager/new-vm" = {
      cpu-default = "host-passthrough";
      firmware = "uefi";
    };

    "org/virt-manager/virt-manager/stats" = {
      enable-disk-poll = true;
      enable-memory-poll = true;
      enable-net-poll = true;
    };
  };
}
