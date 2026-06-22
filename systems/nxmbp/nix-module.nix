{
  config,
  lib,
  ...
}: {
  environment.etc."nix/registry.json" = lib.mkIf (config.nix.registry != null) {
    text = builtins.toJSON {
      version = 2;
      flakes = lib.mapAttrsToList (_n: v: {inherit (v) from to exact;}) config.nix.registry;
    };
  };

  environment.etc."nix/machines" = lib.mkIf (config.nix.buildMachines != []) {
    text =
      lib.concatMapStrings (
        machine:
          (lib.concatStringsSep " " [
            "${lib.optionalString (machine.protocol != null) "${machine.protocol}://"}${
              lib.optionalString (machine.sshUser != null) "${machine.sshUser}@"
            }${machine.hostName}"
            (
              if machine.system != null
              then machine.system
              else if machine.systems != []
              then lib.concatStringsSep "," machine.systems
              else "-"
            )
            (
              if machine.sshKey != null
              then machine.sshKey
              else "-"
            )
            (toString machine.maxJobs)
            (toString machine.speedFactor)
            (
              let
                res = machine.supportedFeatures ++ machine.mandatoryFeatures;
              in
                if (res == [])
                then "-"
                else (lib.concatStringsSep "," res)
            )
            (
              let
                res = machine.mandatoryFeatures;
              in
                if (res == [])
                then "-"
                else (lib.concatStringsSep "," machine.mandatoryFeatures)
            )
            (
              if machine.publicHostKey != null
              then machine.publicHostKey
              else "-"
            )
          ])
          + "\n"
      )
      config.nix.buildMachines;
  };
}
