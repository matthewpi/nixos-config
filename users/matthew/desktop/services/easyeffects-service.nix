{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.services.easyeffects.enable {
    systemd.user.services.easyeffects = {
      Unit = {
        After = lib.mkForce ["pipewire.service"];
        BindsTo = lib.mkForce ["pipewire.service"];
        PartOf = lib.mkForce [];
      };

      Install.WantedBy = lib.mkForce ["pipewire.service"];

      Service = {
        Slice = "background.slice";
        Type = "dbus";
        BusName = "com.github.wwmm.easyeffects";
        ExecStart = lib.mkForce "${lib.getExe config.services.easyeffects.package} --gapplication-service";
        ExecStartPost = [
          "${lib.getExe config.services.easyeffects.package} --load-preset ${config.services.easyeffects.preset}"
        ];
      };
    };
  };
}
