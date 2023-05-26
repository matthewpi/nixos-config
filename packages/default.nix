{
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    packages = let
      # TODO: remove once https://github.com/NixOS/nixpkgs/pull/234267 is merged
      jetbrains = pkgs.callPackage ./overrides/jetbrains.nix {};

      xanmodKernels = pkgs.callPackage ./overrides/xanmod-kernels.nix {
        kernelPatches = [
          pkgs.linuxKernel.kernelPatches.bridge_stp_helper
          pkgs.linuxKernel.kernelPatches.request_key_helper
        ];
      };
    in {
      catppuccin-k9s = pkgs.callPackage ./catppuccin/k9s.nix {};
      catppuccin-plymouth = pkgs.callPackage ./catppuccin/plymouth.nix {};

      fast-syntax-highlighting = pkgs.callPackage ./fast-syntax-highlighting.nix {};

      # TODO: remove once https://github.com/NixOS/nixpkgs/pull/234267 is merged
      jetbrains-goland = jetbrains.goland;

      # linuxPackages_xanmod = pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor xanmodKernels.lts);
      linux_xanmod = xanmodKernels.lts;
      # linuxPackages_xanmod_stable = pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor xanmodKernels.main);
      linux_xanmod_stable = xanmodKernels.main;
      # linuxPackages_xanmod_latest = pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor xanmodKernels.main);
      linux_xanmod_latest = xanmodKernels.main;

      xwaylandvideobridge = pkgs.libsForQt5.callPackage ./xwaylandvideobridge.nix {};
    };

    overlayAttrs = {
      inherit
        (config.packages)
        catppuccin-k9s
        catppuccin-plymouth
        fast-syntax-highlighting
        jetbrains-goland # TODO: remove once https://github.com/NixOS/nixpkgs/pull/234267 is merged
        linux_xanmod_latest
        xwaylandvideobridge
        ;
    };
  };
}
