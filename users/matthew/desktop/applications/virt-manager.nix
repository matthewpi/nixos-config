{
  lib,
  pkgs,
  ...
}: {
  home.packages = [pkgs.virt-manager];

  dconf.settings = {
    "org/virt-manager/virt-manager" = {
      xmleditor-enabled = true;
    };

    "org/virt-manager/virt-manager/new-vm" = {
      cpu-default = "host-passthrough";
      firmware = "uefi";
      graphics-type = "system";
    };

    "org/virt-manager/virt-manager/connections" = {
      autoconnect = lib.hm.gvariant.mkArray lib.hm.gvariant.type.string [
        "qemu+ssh://nxos@nxs.blahaj.systems/system"
      ];
      uris = lib.hm.gvariant.mkArray lib.hm.gvariant.type.string [
        "qemu+ssh://nxos@nxs.blahaj.systems/system"
      ];
    };
  };
}
