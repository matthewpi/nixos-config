{inputs, ...}: {
  perSystem = {
    lib,
    pkgs,
    system,
    ...
  }: let
    fixPathForLazyTrees = input: attr:
      input.packages.${system}.${attr}.overrideAttrs {
        src = builtins.path {
          name = "source";
          path = input;
        };
      };

    _packages = rec {
      catppuccin = pkgs.callPackage ./catppuccin {};
      catppuccin-wallpapers = pkgs.callPackage ./catppuccin/wallpapers {};
      cider2 = pkgs.callPackage ./cider2 {};
      freelens = pkgs.callPackage ./freelens/package.nix {inherit freelens-k8s-proxy;};
      freelens-k8s-proxy = pkgs.callPackage ./freelens-k8s-proxy/package.nix {};
      hoppscotch = pkgs.callPackage ./hoppscotch/package.nix {};
      hoppscotch-desktop = pkgs.callPackage ./hoppscotch-desktop/package.nix {inherit hoppscotch;};
      simple-completion-language-server = pkgs.callPackage ./simple-completion-language-server {};
      fast-syntax-highlighting = pkgs.callPackage ./zsh/fast-syntax-highlighting.nix {};
      inter = pkgs.callPackage ./inter.nix {};
      monaspace = pkgs.callPackage ./monaspace.nix {};
      vencord = inputs.nixpkgs.legacyPackages.${system}.vencord.overrideAttrs (_: {
        version = "1.12.2";
        src = pkgs.fetchFromGitHub {
          owner = "Vendicated";
          repo = "Vencord";
          tag = "v1.12.2";
          hash = "sha256-a4lbeuXEHDMDko8wte7jUdJ0yUcjfq3UPQAuSiz1UQU=";
        };
        meta.platforms = lib.platforms.unix;
      });
      vesktop = inputs.nixpkgs.legacyPackages.${system}.vesktop.override {
        withTTS = false;
        withSystemVencord = true;
        inherit vencord;
        electron = pkgs.electron_36;
      };

      catppuccin-cursors = inputs.nixpkgs.legacyPackages.${system}.catppuccin-cursors.overrideAttrs (_: {
        outputs = ["mochaDark" "out"];

        buildPhase = ''
          runHook preBuild

          patchShebangs .

          just clean
          just build mocha dark

          runHook postBuild
        '';
      });

      tailscale-systray = pkgs.tailscale.overrideAttrs (oldAttrs: rec {
        doCheck = false;
        outputs = ["out"];
        subPackages = ["cmd/systray"];
        postInstall = ''
          mv "$out"/bin/systray "$out"/bin/${meta.mainProgram}
        '';
        meta = oldAttrs.meta // {mainProgram = "tailscale-systray";};
      });

      star-citizen = let
        nix-gaming = inputs.nix-gaming.packages.${pkgs.system};

        winetricks = nix-gaming.winetricks-git;
        inherit (nix-gaming) wineprefix-preparer umu-launcher;

        linuxHeaders = pkgs.makeLinuxHeaders {inherit (pkgs.linuxPackages_xanmod_latest.kernel) src version patches;};

        wine =
          (pkgs.callPackage ./star-citizen/wine.nix {
            inherit inputs;

            # ntsync branch
            src = pkgs.fetchFromGitHub {
              owner = "Kron4ek";
              repo = "wine-tkg";
              rev = "68fba78452e7ede28b573a5f6304a0c353cd3df1";
              hash = "sha256-hRD/0RoD6RtW4YvTDcc/xTMuco1AvsalMMyHrY3TPOk=";
            };

            patches = [
              (pkgs.fetchpatch2 {
                url = "https://raw.githubusercontent.com/starcitizen-lug/patches/98d6a9b6ce102726030bec3ee9ff63e3fad59ad5/wine/cache-committed-size.patch";
                hash = "sha256-cTO6mfKF1MJ0dbaZb76vk4A80OPakxsdoSSe4Og/VdM=";
              })
              (pkgs.fetchpatch2 {
                url = "https://raw.githubusercontent.com/starcitizen-lug/patches/98d6a9b6ce102726030bec3ee9ff63e3fad59ad5/wine/silence-sc-unsupported-os.patch";
                hash = "sha256-/PnXSKPVzSV8tzsofBFT+pNHGUbj8rKrJBg3owz2Stc=";
              })
            ];
          }).overrideAttrs (oldAttrs: {
            # Include linux kernel headers for ntsync.
            buildInputs = oldAttrs.buildInputs ++ [linuxHeaders];

            # Fix `winetricks` by ensuring a `wine64` binary exists.
            postInstall =
              (oldAttrs.postInstall or "")
              + ''
                ln -s "$out"/bin/wine "$out"/bin/wine64
              '';
          });
      in
        pkgs.callPackage ./star-citizen/package.nix {
          inherit wine wineprefix-preparer winetricks umu-launcher;
        };

      aquamarine = (fixPathForLazyTrees inputs.aquamarine "aquamarine").override {
        inherit hyprutils hyprwayland-scanner;
      };

      hyprcursor = (fixPathForLazyTrees inputs.hyprcursor "hyprcursor").override {
        inherit hyprlang;
      };

      hypridle = (fixPathForLazyTrees inputs.hypridle "hypridle").override {
        inherit hyprland-protocols hyprlang hyprutils hyprwayland-scanner;
      };

      hyprland = (fixPathForLazyTrees inputs.hyprland "hyprland").override {
        inherit aquamarine hyprcursor hyprgraphics hyprland-protocols hyprland-qtutils hyprlang hyprutils hyprwayland-scanner;
      };

      hyprland-protocols = fixPathForLazyTrees inputs.hyprland-protocols "hyprland-protocols";

      hyprland-qt-support = (fixPathForLazyTrees inputs.hyprland-qt-support "hyprland-qt-support").override {
        inherit hyprlang;
      };

      hyprland-qtutils = (fixPathForLazyTrees inputs.hyprland-qtutils "hyprland-qtutils").override {
        inherit hyprland-qt-support hyprutils;
      };

      hyprlang = (fixPathForLazyTrees inputs.hyprlang "hyprlang").override {
        inherit hyprutils;
      };

      hyprlock = (fixPathForLazyTrees inputs.hyprlock "hyprlock").override {
        inherit hyprlang hyprgraphics hyprwayland-scanner hyprutils;
      };

      hyprgraphics = (fixPathForLazyTrees inputs.hyprgraphics "hyprgraphics").override {
        inherit hyprutils;
      };

      hyprpaper = (fixPathForLazyTrees inputs.hyprpaper "hyprpaper").override {
        inherit hyprlang hyprgraphics hyprutils hyprwayland-scanner;
      };

      hyprpolkitagent = (fixPathForLazyTrees inputs.hyprpolkitagent "hyprpolkitagent").override {
        inherit hyprland-qt-support hyprutils;
      };

      hyprutils = fixPathForLazyTrees inputs.hyprutils "hyprutils";

      hyprwayland-scanner = fixPathForLazyTrees inputs.hyprwayland-scanner "hyprwayland-scanner";

      xdg-desktop-portal-hyprland = (fixPathForLazyTrees inputs.xdph "xdg-desktop-portal-hyprland").override {
        inherit hyprland hyprland-protocols hyprlang hyprutils hyprwayland-scanner;
      };
    };
  in {
    packages = lib.attrsets.filterAttrs (_: v: builtins.elem system v.meta.platforms) _packages;

    overlayAttrs = let
      _1passwordPreFixup = ''
        makeShellWrapper "$out"/share/1password/1password "$out"/bin/1password \
          "''${gappsWrapperArgs[@]}" \
          --suffix PATH : ${lib.makeBinPath [pkgs.xdg-utils]} \
          --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [pkgs.udev]} \
          --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-wayland-ime=true}}"
      '';
    in (_packages
      // {
        _1password-gui = pkgs._1password-gui.overrideAttrs (_: {preFixup = _1passwordPreFixup;});
        _1password-gui-beta = pkgs._1password-gui-beta.overrideAttrs (_: {preFixup = _1passwordPreFixup;});

        discord = pkgs.discord.override {
          withOpenASAR = true;
          withMoonlight = true;
          withTTS = false;
        };

        mesa = pkgs.mesa.overrideAttrs (oldAttrs: {
          patches =
            (oldAttrs.patches or [])
            ++ [
              # https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/34918
              (pkgs.fetchpatch2 {
                url = "https://raw.githubusercontent.com/Nobara-Project/rpm-sources/refs/heads/42/baseos/mesa/34918.patch";
                hash = "sha256-TbospUjVyC6GkctnEUpSMXKB8PX6mU0GG086tSph0Fc=";
              })
            ];
        });

        signal-desktop = pkgs.signal-desktop.overrideAttrs (old: {
          preFixup =
            old.preFixup
            + ''
              gappsWrapperArgs+=(
                --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --use-tray-icon}}"
              )
            '';
        });
      });
  };
}
