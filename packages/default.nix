{inputs, ...}: {
  flake.overlays.util-linux-fix = _: super: {
    utillinux = super.util-linux;
  };

  perSystem = {
    lib,
    pkgs,
    system,
    ...
  }: let
    _packages = rec {
      _1password-gui = pkgs.callPackage ./1password-gui {};
      _1password-gui-beta = pkgs.callPackage ./1password-gui {channel = "beta";};
      catppuccin = pkgs.callPackage ./catppuccin {};
      catppuccin-wallpapers = pkgs.callPackage ./catppuccin/wallpapers {};
      cider2 = pkgs.callPackage ./cider2 {};
      hoppscotch-unwrapped = pkgs.callPackage ./hoppscotch {};
      hoppscotch = pkgs.callPackage ./hoppscotch/wrapper.nix {inherit hoppscotch-unwrapped;};
      fast-syntax-highlighting = pkgs.callPackage ./zsh/fast-syntax-highlighting.nix {};
      inter = pkgs.callPackage ./inter.nix {};
      monaspace = pkgs.callPackage ./monaspace.nix {};
      zsh-titles = pkgs.callPackage ./zsh/zsh-titles.nix {};
      utillinux = pkgs.util-linux;
    };
  in {
    packages = lib.attrsets.filterAttrs (_: v: builtins.elem system v.meta.platforms) _packages;

    overlayAttrs = let
      _1passwordPreFixup = ''
        makeShellWrapper "$out"/share/1password/1password "$out"/bin/1password \
          "''${gappsWrapperArgs[@]}" \
          --suffix PATH : ${lib.makeBinPath [pkgs.xdg-utils]} \
          --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [pkgs.udev]} \
          --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --use-tray-icon}}"
      '';
    in rec {
      inherit
        (_packages)
        catppuccin
        catppuccin-wallpapers
        cider2
        fast-syntax-highlighting
        hoppscotch-unwrapped
        hoppscotch
        inter
        monaspace
        zsh-titles
        ;

      _1password-gui = _packages._1password-gui.overrideAttrs (_: {preFixup = _1passwordPreFixup;});
      _1password-gui-beta = _packages._1password-gui-beta.overrideAttrs (_: {preFixup = _1passwordPreFixup;});

      signal-desktop = pkgs.signal-desktop.overrideAttrs (old: {
        preFixup =
          old.preFixup
          + ''
            gappsWrapperArgs+=(
              --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --use-tray-icon}}"
            )
          '';
      });

      vesktop = pkgs.vesktop.override {electron = pkgs.electron_32;};

      # Flake overlays
      hyprcursor = inputs.hyprcursor.packages.${system}.hyprcursor;
      hypridle = inputs.hypridle.packages.${system}.hypridle;
      hyprland = inputs.hyprland.packages.${system}.hyprland;
      hyprlang = inputs.hyprlang.packages.${system}.hyprlang;
      hyprlock = inputs.hyprlock.packages.${system}.hyprlock;
      hyprpaper = inputs.hyprpaper.packages.${system}.hyprpaper;
      hyprpolkitagent = inputs.hyprpolkitagent.packages.${system}.hyprpolkitagent;
      xdg-desktop-portal-hyprland = inputs.xdph.packages.${system}.xdg-desktop-portal-hyprland;

      catppuccin-cursors = pkgs.catppuccin-cursors.overrideAttrs (_: rec {
        version = "1.0.1";
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "cursors";
          rev = "v${version}";
          hash = "sha256-l01L0UiE9bgUOMHhs74Bndarw2b6TaJGW/xU/8rfoAk=";
        };
      });

      # Override linux_xanmod with the `netfilter-typo-fix` patch.
      linux_xanmod = pkgs.callPackage "${inputs.nixpkgs}/pkgs/os-specific/linux/kernel/xanmod-kernels.nix" {
        variant = "lts";
        kernelPatches = [
          pkgs.kernelPatches.bridge_stp_helper
          pkgs.kernelPatches.request_key_helper
          pkgs.kernelPatches.netfilter-typo-fix
        ];
      };
      linuxPackages_xanmod = pkgs.linuxPackagesFor linux_xanmod;

      linux_xanmod_latest = pkgs.callPackage "${inputs.nixpkgs}/pkgs/os-specific/linux/kernel/xanmod-kernels.nix" {
        variant = "main";
        kernelPatches = [
          pkgs.kernelPatches.bridge_stp_helper
          pkgs.kernelPatches.request_key_helper
          pkgs.kernelPatches.netfilter-typo-fix
        ];
      };
      linuxPackages_xanmod_latest = pkgs.linuxPackagesFor linux_xanmod_latest;

      linux_xanmod_stable = linux_xanmod_latest;
      inuxPackages_xanmod_stable = pkgs.linuxPackagesFor linux_xanmod_stable;
    };
  };
}
