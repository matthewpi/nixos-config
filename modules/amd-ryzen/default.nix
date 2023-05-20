{
  flake.nixosModules.amd-ryzen = {
    config,
    lib,
    ...
  }: {
    # Enable zenpower
    boot.extraModulePackages = with config.boot.kernelPackages; [zenpower];

    # Disable k10temp as it conflicts with zenpower
    boot.blacklistedKernelModules = [
      "k10temp"
    ];

    # Enable amd_pstate correctly
    boot.kernelParams =
      if lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.3"
      then [
        "amd_pstate=active"
      ]
      else [
        "amd_pstate=passive"
        "amd_pstate.shared_mem=1"
      ];
  };
}
