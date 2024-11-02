{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.services.geoclue2.enable {
    systemd.user.services.geoclue-agent.serviceConfig.Slice = "background.slice";
  };
}
