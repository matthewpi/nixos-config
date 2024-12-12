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
      gauntlet = pkgs.callPackage ./gauntlet/package.nix {};
      hoppscotch = pkgs.callPackage ./hoppscotch {};
      hoppscotch-desktop-unwrapped = pkgs.callPackage ./hoppscotch-desktop {inherit hoppscotch;};
      hoppscotch-desktop = pkgs.callPackage ./hoppscotch-desktop/wrapper.nix {inherit hoppscotch-desktop-unwrapped;};
      package-version-server = pkgs.callPackage ./package-version-server {};
      simple-completion-language-server = pkgs.callPackage ./simple-completion-language-server {};
      fast-syntax-highlighting = pkgs.callPackage ./zsh/fast-syntax-highlighting.nix {};
      inter = pkgs.callPackage ./inter.nix {};
      monaspace = pkgs.callPackage ./monaspace.nix {};
      vesktop = pkgs.callPackage ./vesktop/package.nix {vesktop = pkgs.vesktop;};
      zsh-titles = pkgs.callPackage ./zsh/zsh-titles.nix {};

      catppuccin-cursors = pkgs.catppuccin-cursors.overrideAttrs (oldAttrs: {
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "cursors";
          rev = "refs/tags/v1.0.2";
          hash = "sha256-Mm0fRh/Shem65E/Cl0yyw+efEHOEt/OJ+MzL+3Mcbwc=";
        };

        nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [pkgs.zip];

        outputs = ["mochaDark" "out"];

        buildPhase = ''
          runHook preBuild

          patchShebangs .

          just clean
          just build mocha dark

          runHook postBuild
        '';
      });

      zed-editor = pkgs.zed-editor.overrideAttrs (_: rec {
        pname = "zed-editor";
        version = "0.166.0-pre";

        src = pkgs.fetchFromGitHub {
          owner = "zed-industries";
          repo = "zed";
          rev = "refs/tags/v${version}";
          hash = "sha256-ihK5VFZ0NDR+f+23DhccUsZk5pDZYjpCE9psYYc+be0=";
        };

        cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
          inherit src;
          name = "${pname}-${version}";
          hash = "sha256-Of9WQ2f9fKwjUQuoSeJMH64Y35VL+xgIf6H5r+MKtAE=";
        };

        env = {
          LK_CUSTOM_WEBRTC = pkgs.fetchzip (let
            version = "webrtc-dac8015-6";

            os =
              if pkgs.stdenv.isLinux
              then "linux"
              else
                (
                  if pkgs.stdenv.isDarwin
                  then "mac"
                  else throw "unknown os"
                );
            arch =
              if pkgs.stdenv.isx86_64
              then "x64"
              else
                (
                  if pkgs.stdenv.isAarch64
                  then "arm64"
                  else throw "unknown arch"
                );
          in {
            url = "https://github.com/livekit/rust-sdks/releases/download/${version}/webrtc-${os}-${arch}-release.zip";
            hash = "sha256-fMTNBML90awpJroxIFsADQ6owCEQeQTAUZOLbBcycGo=";
            stripRoot = true;
          });

          FONTCONFIG_FILE = pkgs.makeFontsConf {
            fontDirectories = [
              "${src}/assets/fonts/plex-mono"
              "${src}/assets/fonts/plex-sans"
            ];
          };

          RELEASE_VERSION = version;
        };
      });
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
    in {
      inherit
        (_packages)
        catppuccin
        catppuccin-cursors
        catppuccin-wallpapers
        cider2
        fast-syntax-highlighting
        gauntlet
        hoppscotch-desktop-unwrapped
        hoppscotch-desktop
        package-version-server
        simple-completion-language-server
        inter
        monaspace
        vesktop
        zed-editor
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

      # Flake overlays
      hyprcursor = inputs.hyprcursor.packages.${system}.hyprcursor;
      hypridle = inputs.hypridle.packages.${system}.hypridle;
      hyprland = inputs.hyprland.packages.${system}.hyprland;
      hyprlang = inputs.hyprlang.packages.${system}.hyprlang;
      hyprlock = inputs.hyprlock.packages.${system}.hyprlock;
      hyprpaper = inputs.hyprpaper.packages.${system}.hyprpaper;
      hyprpolkitagent = inputs.hyprpolkitagent.packages.${system}.hyprpolkitagent;
      xdg-desktop-portal-hyprland = inputs.xdph.packages.${system}.xdg-desktop-portal-hyprland;
    };
  };
}
