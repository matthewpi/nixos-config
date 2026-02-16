{
  cctools,
  copyDesktopItems,
  electron_39,
  fetchFromGitHub,
  fetchPnpmDeps,
  lib,
  makeDesktopItem,
  makeWrapper,
  nodejs_24,
  pnpm_10,
  pnpmConfigHook,
  python3,
  stdenv,
}: let
  electron = electron_39;
  pnpm = pnpm_10.override {nodejs = nodejs_24;};
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "fluxer";
    version = "0-unstable-2026-02-12";

    src = fetchFromGitHub {
      owner = "fluxerapp";
      repo = "fluxer";
      rev = "cb316085235723e68fce5b5b7f86befca8e47c09";
      hash = "sha256-7en5pENPCP9g4Bm+WXEKcIVb1kf28H1KlPmeHkX9LNM=";
    };

    sourceRoot = "${finalAttrs.src.name}/fluxer_app";

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src sourceRoot;
      inherit pnpm;
      fetcherVersion = 3;
      hash = "sha256-zJTjNfNWMhQtEwY1lik2H9xMf4lJ6GLg6PShva7IDjs=";
    };

    strictDeps = true;
    nativeBuildInputs =
      [
        makeWrapper
        nodejs_24
        pnpm
        pnpmConfigHook
        python3
      ]
      ++ lib.optional stdenv.hostPlatform.isLinux copyDesktopItems
      ++ lib.optional stdenv.hostPlatform.isDarwin cctools.libtool;

    env = {
      # Ensure electron-builder doesn't try to download any binaries as that
      # won't work in the Nix build sandbox.
      ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

      # Set NODE_ENV so the build scripts know we are building for a production
      # release.
      NODE_ENV = "production";
    };

    configurePhase = ''
      runHook preConfigure

      export npm_config_nodedir=${electron.headers}

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild

      # Build the application.
      pnpm run electron:compile

      # electronDist needs to be modifiable on Darwin
      cp -r ${electron.dist} electron-dist
      chmod -R u+w electron-dist

      # Run electron-builder to bundle the application, making sure it uses electron from nixpkgs.
      pnpm exec electron-builder \
        --publish never \
        --dir \
        --config electron-builder.config.cjs \
        -c.electronDist=electron-dist \
        -c.electronVersion=${electron.version}

      runHook postBuild
    '';

    # TODO: add svg logo
    installPhase = ''
      runHook preInstall

      ${(
        if stdenv.hostPlatform.isDarwin
        then ''
          mkdir -p "$out"/Applications
          cp -r dist-electron/mac*/Fluxer.app "$out"/Applications
        ''
        else ''
          mkdir -p "$out"/share/fluxer
          cp -r dist-electron/*-unpacked/{locales,resources{,.pak}} "$out"/share/fluxer

          for i in 16 32 48 64 128 256 512 1024; do
            install -Dm644 electron-build-resources/icons-stable/"$i"x"$i".png "$out"/share/icons/hicolor/"$i"x"$i"/apps/fluxer.png
          done

          makeWrapper ${lib.getExe electron} "$out"/bin/fluxer \
            --add-flag "$out"/share/fluxer/resources/app.asar \
            --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-wayland-ime=true --enable-features=WaylandWindowDecorations --enable-features=WebRTCPipeWireCapturer}}" \
            --inherit-argv0
        ''
      )}

      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "fluxer";
        desktopName = "Fluxer";
        exec = "fluxer %U";
        icon = "fluxer";
        comment = finalAttrs.meta.description;
        categories = ["Network"];
        startupWMClass = "fluxer";
        mimeTypes = ["x-scheme-handler/fluxer"];
      })
    ];

    meta = {
      mainProgram = "fluxer";
      description = "Free and open source instant messaging and VoIP platform";
      homepage = "https://fluxer.app/";
      # TODO: changelog once one is available
      license = lib.licenses.agpl3Only;
      maintainers = with lib.maintainers; [matthewpi];
      platforms = lib.platforms.linux ++ lib.platforms.darwin;
    };
  })
