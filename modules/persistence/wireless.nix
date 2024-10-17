{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.networking.wireless.enable && config.networking.wireless.allowAuxiliaryImperativeNetworks) {
    environment.persistence."/persist".directories = ["/etc/wpa_supplicant"];
  };
}
