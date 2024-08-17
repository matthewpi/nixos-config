{
  applyPatches,
  buildLinux,
  fetchFromGitHub,
  lib,
  stdenv,
  ...
} @ args: let
  # These names are how they are designated in https://xanmod.org.
  # NOTE: When updating these, please also take a look at the changes done to
  # kernel config in the xanmod version commit
  mainVariant = {
    version = "6.10.5";
    hash = "sha256-tETGtCNNgYj1IUNuI/Am5kimFndUC4O+cZwZzlPitFA=";
  };

  xanmodKernelFor = {
    version,
    suffix ? "xanmod1",
    hash,
  }:
    buildLinux (args
      // rec {
        inherit version;
        modDirVersion = lib.versions.pad 3 "${version}-${suffix}";

        src = applyPatches {
          src = fetchFromGitHub {
            owner = "xanmod";
            repo = "linux";
            rev = modDirVersion;
            inherit hash;
          };
          patches = [
            ./oled_vrr.patch
            ./90e3a855c922d0b8c4b18c886c5cf73223d69475.patch
          ];
        };

        structuredExtraConfig = with lib.kernel; {
          # Google's BBRv3 TCP congestion Control
          TCP_CONG_BBR = yes;
          DEFAULT_BBR = yes;

          # Preemptive Full Tickless Kernel at 250Hz
          HZ = freeform "250";
          HZ_250 = yes;
          HZ_1000 = no;

          DRM_AMD_COLOR_STEAMDECK = yes;
        };

        extraMeta = {
          branch = lib.versions.majorMinor version;
          maintainers = with lib.maintainers; [matthewpi];
          description = "Built with custom settings and new features built to provide a stable, responsive and smooth desktop experience";
          broken = stdenv.isAarch64;
        };
      }
      // (args.argsOverride or {}));
in {
  main = xanmodKernelFor mainVariant;
}
