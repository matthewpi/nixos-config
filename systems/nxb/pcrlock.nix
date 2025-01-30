{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.systemd.pcrlock;
in {
  options.systemd.pcrlock = {
    enable = lib.mkOption {
      description = "Whether to enable the activation of systemd-pcrlock.";
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable (let
    systemd-pcrlock = pkgs.runCommand "systemd-pcrlock" {} ''
      mkdir -p "$out"/bin
      ln -s ${config.systemd.package}/lib/systemd/systemd-pcrlock "$out"/bin
    '';
  in {
    boot.initrd.systemd.tpm2.enable = true;
    boot.initrd.systemd.storePaths = ["${config.boot.initrd.systemd.package}/lib/systemd/systemd-pcrextend"];

    boot.initrd.systemd.additionalUpstreamUnits = ["systemd-pcrphase-initrd.service"];

    boot.initrd.systemd.targets.initrd.wants = ["systemd-pcrphase-initrd.service"];

    systemd.additionalUpstreamSystemUnits = [
      "systemd-pcrextend@.service"
      "systemd-pcrextend.socket"
      "systemd-pcrfs-root.service"
      "systemd-pcrfs@.service"
      "systemd-pcrmachine.service"
      "systemd-pcrphase.service"
      "systemd-pcrphase-sysinit.service"

      "systemd-pcrlock-file-system.service"
      "systemd-pcrlock-firmware-code.service"
      "systemd-pcrlock-firmware-config.service"
      "systemd-pcrlock-machine-id.service"
      # "systemd-pcrlock-make-policy.service"
      "systemd-pcrlock-secureboot-authority.service"
      "systemd-pcrlock-secureboot-policy.service"
      # "systemd-pcrlock@.service"
      # "systemd-pcrlock.socket"
    ];

    systemd.targets.sysinit.wants = [
      "systemd-pcrlock-file-system.service"
      "systemd-pcrlock-firmware-code.service"
      "systemd-pcrlock-firmware-config.service"
      "systemd-pcrlock-machine-id.service"
      "systemd-pcrlock-make-policy.service"
      "systemd-pcrlock-secureboot-authority.service"
      "systemd-pcrlock-secureboot-policy.service"
    ];

    # https://github.com/systemd/systemd/issues/34512#issuecomment-2364156638
    systemd.services.systemd-pcrlock-make-policy.serviceConfig.ExecStart = lib.mkForce [
      " " # required to unset the previous value.
      "${config.systemd.package}/lib/systemd/systemd-pcrlock make-policy --location=831"
    ];

    environment.etc."pcrlock.d".source = "${config.systemd.package}/lib/pcrlock.d";

    environment.systemPackages = [
      # Link `systemd-pcrlock` since it isn't "installed" by default.
      systemd-pcrlock
      # JQ is useful for parsing the output of `systemd-pcrlock`.
      pkgs.jq
    ];
  });
}
