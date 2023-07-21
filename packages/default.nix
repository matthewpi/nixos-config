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
      _1password-gui = pkgs.callPackage ./1password-gui/default.nix {};
      _1password-gui-beta = pkgs.callPackage ./1password-gui/default.nix {channel = "beta";};

      blackbox-terminal = pkgs.callPackage ./overrides/blackbox-terminal.nix {};

      catppuccin-k9s = pkgs.callPackage ./catppuccin/k9s.nix {};
      catppuccin-plymouth = pkgs.callPackage ./catppuccin/plymouth.nix {};

      fast-syntax-highlighting = pkgs.callPackage ./fast-syntax-highlighting.nix {};

      linux_xanmod = xanmodKernels.lts;
      linux_xanmod_stable = xanmodKernels.main;
      linux_xanmod_latest = xanmodKernels.main;

      xwaylandvideobridge = pkgs.libsForQt5.callPackage ./xwaylandvideobridge.nix {};
    };

    overlayAttrs = {
      inherit
        (config.packages)
        _1password-gui
        _1password-gui-beta
        blackbox-terminal
        catppuccin-k9s
        catppuccin-plymouth
        fast-syntax-highlighting
        linux_xanmod
        linux_xanmod_stable
        linux_xanmod_latest
        xwaylandvideobridge
        ;
    };
  };
}
