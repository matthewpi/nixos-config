{
  cctools,
  copyDesktopItems,
  electron_39,
  fetchFromGitHub,
  fetchPnpmDeps,
  freelens-k8s-proxy,
  kubectl,
  kubernetes-helm,
  lib,
  makeDesktopItem,
  makeWrapper,
  nodejs_22,
  pnpm_10,
  pnpmConfigHook,
  python3,
  stdenv,
}: let
  electron = electron_39;
  pnpm = pnpm_10.override {nodejs = nodejs_22;};

  # https://www.electron.build/builder-util.typealias.archtype
  binaryArchitecture =
    {
      "amd64" = "x64";
      "arm64" = "arm64";
    }.${
      stdenv.hostPlatform.go.GOARCH
    };
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "freelens";
    version = "1.8.1";

    src = fetchFromGitHub {
      owner = "freelensapp";
      repo = "freelens";
      tag = "v${finalAttrs.version}";
      hash = "sha256-/vcC9JHFJUhMkOIPINttxYB14DDi5ZzYPzQ6iCSTfZs=";
    };

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      inherit pnpm;
      fetcherVersion = 3;
      hash = "sha256-SSpfeTAj0223LkyLFEFMDjr63wDKkqXWc4VKWpTyO18=";
    };

    strictDeps = true;
    nativeBuildInputs =
      [
        makeWrapper
        nodejs_22
        pnpm
        pnpmConfigHook
        python3
      ]
      ++ lib.optional stdenv.hostPlatform.isLinux copyDesktopItems
      ++ lib.optional stdenv.hostPlatform.isDarwin cctools.libtool;

    env =
      {
        # Ensure electron-builder doesn't try to download any binaries as that
        # won't work in the Nix build sandbox.
        ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

        # Set NODE_ENV so the build scripts know we are building for a production
        # release.
        NODE_ENV = "production";

        # Needed to prevent the downloading of binaries for kubectl, helm, etc
        # during the build process of `freelens`. Instead, we symlink these
        # binaries from nixpkgs.
        #
        # ref; https://github.com/freelensapp/freelens/blob/v1.3.0/packages/ensure-binaries/src/index.mts#L98
        LENS_SKIP_DOWNLOAD_BINARIES = "true";
      }
      // lib.optionalAttrs stdenv.hostPlatform.isDarwin {
        # Disable electron-builder codesigning on Darwin.
        CSC_IDENTITY_AUTO_DISCOVERY = "false";
      };

    configurePhase = ''
      runHook preConfigure

      export npm_config_nodedir=${electron.headers}

      runHook postConfigure
    '';

    preBuild =
      # Use `.local/share` instead of `.freelens` for extensions.
      ''
        substituteInPlace packages/core/src/extensions/extension-discovery/extension-discovery.ts \
          --replace-fail '".freelens", "extensions"' '".local", "share", "Freelens"'
      ''
      # Without this `process.resourcesPath` will point to `${electron}/libexec`,
      # which will not work.
      #
      # For Darwin, we use symlinks in the `Freelens.app/Contents/Resources` directory.
      + lib.optionalString stdenv.hostPlatform.isLinux ''
        substituteInPlace packages/core/src/common/vars/lens-resources-dir.injectable.ts \
          --replace-fail 'process.resourcesPath' "'$out/share/freelens/resources'"
      '';

    postPatch = ''
      sed -i -e 's/corepack //g' freelens/package.json
      sed -i '/"build:resources:client"/d' freelens/package.json
    '';

    buildPhase = ''
      runHook preBuild

      # Build the application and all of it's dependencies in the monorepo.
      pnpm run build

      # Switch to the directory where the Electron application is located.
      cd freelens

      # Pre-build the electron part of the application.
      pnpm electron-rebuild

      # electronDist needs to be modifiable on Darwin
      cp -r ${electron.dist} electron-dist
      chmod -R u+w electron-dist

      # Run electron-builder, making sure it uses the electron from nixpkgs.
      pnpm exec electron-builder \
        --publish never \
        --dir \
        --config electron-builder.yml \
        -c.electronDist=electron-dist \
        -c.electronVersion=${electron.version} \
        -c.mac.identity=null

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      ${(
        if stdenv.hostPlatform.isDarwin
        then ''
          mkdir -p "$out"/Applications
          cp -r dist/mac*/Freelens.app "$out"/Applications

          mkdir "$out"/Applications/Freelens.app/Contents/Resources/${binaryArchitecture}
          pushd "$out"/Applications/Freelens.app/Contents/Resources/${binaryArchitecture}
          ln -s ${lib.getExe freelens-k8s-proxy} freelens-k8s-proxy
          ln -s ${lib.getExe kubernetes-helm} helm
          ln -s ${lib.getExe kubectl} kubectl
          popd

          # ln -s "$out"/Applications/Freelens.app/Contents/MacOS/Freelens "$out"/bin/freelens
          # makeWrapper "$out"/Applications/Freelens.app/Contents/MacOS/Freelens "$out"/bin/freelens
        ''
        else ''
          mkdir -p "$out"/share/freelens
          cp -r dist/*-unpacked/{locales,resources{,.pak}} "$out"/share/freelens

          mkdir -p "$out"/share/freelens/resources/${binaryArchitecture}
          pushd "$out"/share/freelens/resources/${binaryArchitecture}
          ln -s ${lib.getExe freelens-k8s-proxy} freelens-k8s-proxy
          ln -s ${lib.getExe kubernetes-helm} helm
          ln -s ${lib.getExe kubectl} kubectl
          popd

          install -Dm644 build/icon.svg "$out"/share/icons/hicolor/scalable/apps/freelens.svg
          for i in 16 32 64 128 256 512; do
            install -Dm644 build/icons/"$i"x"$i".png "$out"/share/icons/hicolor/"$i"x"$i"/apps/freelens.png
          done

          makeWrapper ${lib.getExe electron} "$out"/bin/freelens \
            --add-flag "$out"/share/freelens/resources/app.asar \
            --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-wayland-ime=true --enable-features=WaylandWindowDecorations --enable-features=WebRTCPipeWireCapturer --disable-gpu-compositing}}" \
            --inherit-argv0
        ''
      )}

      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "freelens";
        desktopName = "Freelens";
        exec = "freelens %U";
        icon = "freelens";
        comment = "Free IDE for Kubernetes.";
        categories = ["Development"];
        startupWMClass = "Freelens";
        mimeTypes = ["x-scheme-handler/freelens"];
      })
    ];

    meta = {
      mainProgram = "freelens";
      description = "Free IDE for Kubernetes";
      homepage = "https://freelensapp.github.io/";
      changelog = "https://github.com/freelensapp/freelens/releases/tag/${finalAttrs.src.tag}";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [matthewpi];
      platforms = lib.platforms.linux ++ lib.platforms.darwin;
    };
  })
