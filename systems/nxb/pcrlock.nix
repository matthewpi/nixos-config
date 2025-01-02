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
      "systemd-pcrlock-make-policy.service"
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

    # systemd.tmpfiles.settings."20-pcrlock" = {
    #   # "/var/lib/pcrlock.d/560-boot-loader.pcrlock.d/generated.pcrlock"."C+".argument = builtins.toString (pkgs.writeText "generated.pcrlock" ''
    #   #   {"records":[{"pcr":4,"digests":[{"hashAlg":"sha1","digest":"19e2b51dfa4f3e27a7f8c1e9b1b2e9afb3e76d4f"},{"hashAlg":"sha256","digest":"f72dd667a2bd510147926ab8a5699f55150bd547465126defa00e5cca5268db8"},{"hashAlg":"sha384","digest":"c70650eb4969ad0a3a51a4a1072d3d8eaacbded3eb00aac4c41527523f05d2b506a9e31c688b9680980963159e0ca1bc"},{"hashAlg":"sha512","digest":"f838710b675a522783b57a421eac003ce00c1d26c72144d87a773c8d34218faf5eb1252e6a7d28548697db26f2036f71af1c9fa1a7864bf5d697e61eed4cf4ae"}]}]}
    #   # '');
    # };
  });
}
