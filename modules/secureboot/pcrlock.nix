{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.systemd.pcrlock;

  systemd-pcrlock = pkgs.runCommand "systemd-pcrlock" {meta.mainProgram = "systemd-pcrlock";} ''
    mkdir -p "$out"/bin
    ln -s ${config.systemd.package}/lib/systemd/systemd-pcrlock "$out"/bin
  '';

  predictions = pkgs.runCommand "pcrlock.d" {} ''
    mkdir -p "$out"/lib
    cp -r ${config.systemd.package}/lib/pcrlock.d "$out"/lib/
    chmod 755 "$out"/lib/pcrlock.d
    ${lib.concatMapAttrsStringSep "\n" (name: value: ''install -Dm644 ${value.source} "$out"/lib/pcrlock.d/${name}'') cfg.predictions}
  '';
in {
  options.systemd.pcrlock = {
    enable =
      lib.mkEnableOption null
      // {
        description = "Whether to enable the activation of systemd-pcrlock.";
        default = true;
      };

    package = lib.mkOption {
      description = "The systemd-pcrlock package to use.";
      type = lib.types.package;
      default = systemd-pcrlock;
    };

    makePolicy = lib.mkOption {
      description = "Whether to enable `systemd-pcrlock-make-policy.service` to run automatically on boot.";
      type = lib.types.bool;
      default = false;
    };

    predictions = lib.mkOption {
      description = "Predictions to add to `/etc/pcrlock.d`.";
      default = {};
      type = lib.types.attrsOf (lib.types.submodule (
        {
          config,
          name,
          options,
          ...
        }: {
          options = {
            enable = lib.mkOption {
              description = ''
                Whether this /etc/pcrlock.d file should be generated. This
                option allows specific /etc/pcrlock.d files to be disabled.
              '';
              type = lib.types.bool;
              default = true;
              example = false;
            };

            text = lib.mkOption {
              description = "Text of the file.";
              type = lib.types.nullOr lib.types.lines;
              default = null;
            };

            source = lib.mkOption {
              description = "Path of the source file.";
              type = lib.types.path;
            };
          };

          config.source = lib.mkIf (config.text != null) (
            let
              name' = "pcrlock-" + lib.replaceStrings ["/"] ["-"] name;
            in
              lib.mkDerivedConfig options.text (pkgs.writeText name')
          );
        }
      ));
    };
  };

  config = lib.mkIf cfg.enable {
    # Install `systemd-pcrlock` so it's CLI can be easily accessed.
    environment.systemPackages = [
      # Link `systemd-pcrlock` since it isn't "installed" by default.
      cfg.package
      # JQ is useful for parsing the output of `systemd-pcrlock`.
      pkgs.jq
    ];

    # Add the configured predictions to `/etc/pcrlock.d` so they are
    # automatically picked up by systemd.
    environment.etc."pcrlock.d".source = "${predictions}/lib/pcrlock.d";

    # NOTE: this is not really necessary for pcrlock, but since pcrlock is
    # only useful with a TPM, we might as well enable it.
    security.tpm2.enable = lib.mkDefault true;

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
      "systemd-pcrlock-make-policy.service"
      "systemd-pcrlock-secureboot-authority.service"
      "systemd-pcrlock-secureboot-policy.service"
      # "systemd-pcrlock@.service"
      # "systemd-pcrlock.socket"
    ];

    systemd.targets.sysinit.wants =
      [
        "systemd-pcrlock-file-system.service"
        "systemd-pcrlock-firmware-code.service"
        "systemd-pcrlock-firmware-config.service"
        "systemd-pcrlock-machine-id.service"
        "systemd-pcrlock-secureboot-authority.service"
        "systemd-pcrlock-secureboot-policy.service"
      ]
      ++ lib.optional cfg.makePolicy "systemd-pcrlock-make-policy.service";

    # https://github.com/systemd/systemd/issues/34512#issuecomment-2364156638
    systemd.services.systemd-pcrlock-make-policy.serviceConfig.ExecStart = lib.mkForce [
      " " # required to unset the previous value.
      "${lib.getExe cfg.package} make-policy --location=831"
    ];
  };
}
