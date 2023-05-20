{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.services.openssh.enable {
    environment.persistence."/persist".files = lib.concatMap (key: [key.path (key.path + ".pub")]) config.services.openssh.hostKeys;
  };
}
