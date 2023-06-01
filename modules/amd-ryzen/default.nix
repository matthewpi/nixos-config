{
  flake.nixosModules.amd-ryzen = {config, ...}: {
    # Enable zenpower
    boot.extraModulePackages = with config.boot.kernelPackages; [zenpower];

    # Disable k10temp as it conflicts with zenpower
    boot.blacklistedKernelModules = [
      "k10temp"
    ];
  };
}
