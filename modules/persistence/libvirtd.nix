{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.virtualisation.libvirtd.enable {
    environment.persistence."/persist".directories = ["/var/lib/libvirt"];
  };
}
