{
  copyDesktopItems,
  electron_35,
  fetchFromGitHub,
  freelens-k8s-proxy,
  kubectl,
  kubernetes-helm,
  lib,
  makeDesktopItem,
  makeWrapper,
  nodejs_22,
  pnpm_10,
  python3,
  stdenv,
}: let
  electron = electron_35;
  nodejs = nodejs_22;
  pnpm = pnpm_10;

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
    version = "1.3.2";

    src = fetchFromGitHub {
      owner = "freelensapp";
      repo = "freelens";
      tag = "v${finalAttrs.version}";
      hash = "sha256-V39LP5NoxegpTvxMKQ716d3ontpHi0OYdFtQnV4RmJ4=";
    };

    pnpmDeps = pnpm.fetchDeps {
      inherit (finalAttrs) pname version src;
      hash = "sha256-tisDCKklgSYyt6T3dcH82BtDQhaj87t/a1qGEzgXB2w=";
    };

    strictDeps = true;
    nativeBuildInputs = [
      copyDesktopItems
      makeWrapper
      nodejs
      pnpm.configHook
      python3
    ];

    env = {
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
    };

    configurePhase = ''
      runHook preConfigure

      export npm_config_nodedir=${electron.headers}

      runHook postConfigure
    '';

    # Without this `process.resourcesPath` will point to `${electron}/libexec`,
    # which will not work.
    #
    # TODO: do we need to do something similar for darwin?
    preBuild = lib.optionalString stdenv.hostPlatform.isLinux ''
      substituteInPlace packages/core/src/common/vars/lens-resources-dir.injectable.ts \
        --replace-fail 'process.resourcesPath' "'$out/share/freelens/resources'"
    '';

    buildPhase = ''
      runHook preBuild

      # Build the application and all of it's dependencies in the monorepo.
      pnpm run --recursive --use-stderr --stream build

      # Switch to the directory where the Electron application is located.
      cd freelens

      # Pre-build the electron part of the application.
      pnpm run prebuild:app

      # Run electron-builder, making sure it uses the electron from nixpkgs.
      pnpm exec electron-builder \
        --publish never \
        --dir \
        --config electron-builder.yml \
        -c.electronDist=${electron.dist} \
        -c.electronVersion=${electron.version}

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      ${(
        if stdenv.hostPlatform.isDarwin
        then ''
          mkdir -p "$out"/Applications
          cp -r dist/mac*/Freelens.app "$out"/Applications

          # TODO: link binaries like we do for Linux.

          # makeWrapper "$out"/Applications/Freelens.app/Contents/MacOS/freelens "$out"/bin/freelens
        ''
        else ''
          mkdir -p "$out"/share/freelens
          cp -r dist/*-unpacked/{locales,resources{,.pak}} "$out"/share/freelens

          # TODO: figure out if we really need this or not. While the application
          # needs these binaries, we really don't want to trigger a rebuild of
          # freelens, just because kubectl was updated. Ideally we would provide
          # these in a wrapper (separate of the application build) and ensure
          # freelens can read them from `$PATH` automatically. That way only
          # the wrapper gets rebuild if any of these binaries change, not the
          # entire application.
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
