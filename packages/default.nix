{
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    packages = let
      xanmodKernels = pkgs.callPackage ./overrides/xanmod-kernels.nix {
        kernelPatches = [
          pkgs.linuxKernel.kernelPatches.bridge_stp_helper
          pkgs.linuxKernel.kernelPatches.request_key_helper
        ];
      };
    in {
      catppuccin-plymouth = pkgs.callPackage ./catppuccin/plymouth.nix {};

      fast-syntax-highlighting = pkgs.callPackage ./fast-syntax-highlighting.nix {};

      xwaylandvideobridge = pkgs.libsForQt5.callPackage ./xwaylandvideobridge.nix {};

      # linuxPackages_xanmod = pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor xanmodKernels.lts);
      linux_xanmod = xanmodKernels.lts;

      # linuxPackages_xanmod_stable = pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor xanmodKernels.main);
      linux_xanmod_stable = xanmodKernels.main;

      # linuxPackages_xanmod_latest = pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor xanmodKernels.main);
      linux_xanmod_latest = xanmodKernels.main;
    };

    overlayAttrs = {
      inherit
        (config.packages)
        catppuccin-plymouth
        fast-syntax-highlighting
        xwaylandvideobridge
        linux_xanmod_latest
        ;
    };
  };
}
