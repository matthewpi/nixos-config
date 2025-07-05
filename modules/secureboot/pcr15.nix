{
  config,
  lib,
  ...
}: let
  cfg = config.boot.initrd.systemIdentity;
in {
  options.boot.initrd.systemIdentity = {
    enable = lib.mkEnableOption ''
      Enable the verification of the system's identity (PCR 15) in the initrd.
    '';

    pcr15 = lib.mkOption {
      description = ''
        Value of PCR 15 after all LUKS partitions have been unlocked. It should
        be a hex-encoded string with a length of 64 characters (SHA-256).

        If your system is already booted, you can get this value by running
        {command}`systemd-analyze pcrs --json=short 15`.

        If this value is set to `null` (the default), PCR 15 will not be verified.
      '';
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "183c33ce59767187c3b1da427b71de134818608c8a006dd3519d9ccf4d28c01d";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.pcr15 != null) {
    # Configure a service that runs in the initrd after disk decryption but
    # before the root filesystem is mounted.
    #
    # This service is used to verify PCR 15 (system-identity) to ensure that
    # the disk that was decrypted is the one we wanted. Without this, a
    # malicious actor could replace the LUKS parition with a fake one and a
    # custom `init` binary that would allow them to extract the key from the
    # TPM, allowing them to unlock our disk and gain full access to it's contents.
    boot.initrd.systemd.services.verify-system-identity = {
      after = ["cryptsetup.target"];
      before = ["sysroot.mount"];
      requiredBy = ["sysroot.mount"];
      unitConfig.DefaultDependencies = "no";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        echo 'Verifying system identity...'
        if [ "$(systemd-analyze pcrs --json=short 15)" != '[{"nr":15,"name":"system-identity","sha256":"${cfg.pcr15}"}]' ]; then
          echo 'Failed to verify system identity, aborting!'
          exit 1
        fi
        echo 'System identity verified.'
      '';
    };
  };
}
