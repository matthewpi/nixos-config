{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.services.easyeffects.enable {
    systemd.user.services.easyeffects.Service = {
      Type = "dbus";
      BusName = "com.github.wwmm.easyeffects";
      ExecStart = lib.mkForce "${lib.getExe config.services.easyeffects.package} --gapplication-service";
      ExecStartPost = [
        "${lib.getExe config.services.easyeffects.package} --load-preset ${config.services.easyeffects.preset}"
      ];
    };
  };
}
