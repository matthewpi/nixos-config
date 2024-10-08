{
  cacert,
  cargo-tauri,
  darwin,
  desktop-file-utils,
  fetchFromGitHub,
  gcc,
  glib-networking,
  gtk3,
  lib,
  libayatana-appindicator,
  libsoup,
  nodejs,
  node-gyp,
  node-pre-gyp,
  openssl,
  python3,
  pkg-config,
  pnpm_9,
  prisma,
  prisma-engines,
  rustPlatform,
  stdenv,
  webkitgtk,
  wrapGAppsHook3,
}: let
  pnpm = pnpm_9;
in
  rustPlatform.buildRustPackage rec {
    pname = "hoppscotch-unwrapped";
    version = "2024.9.1";

    src = fetchFromGitHub {
      owner = "hoppscotch";
      repo = "hoppscotch";
      rev = version;
      hash = "sha256-jaVUJ1ymcOPM198DSAdK5G0fvuM1agUmpbk9rwM710Q=";
    };

    cargoLock = {
      lockFile = ./Cargo.lock;
      outputHashes = {
        "tauri-plugin-deep-link-0.1.2" = "sha256-RlMTfUTcM2FAuQ5GNyUrtQK0WZ+kBk+FGzTuSAVdf0c=";
        "tauri-plugin-store-0.0.0" = "sha256-Mf2/cnKotd751ZcSHfiSLNe2nxBfo4dMBdoCwQhe7yI=";
      };
    };

    postPatch = ''
      ln -s ${./Cargo.lock} Cargo.lock
    '';

    # TODO: cargoRoot = "packages/hoppscotch-selfhost-desktop/src-tauri";

    # could not find `Cargo.toml` in `/build/source` or any parent directory
    # probably need `cargoRoot`
    doCheck = false;

    pnpmDeps = pnpm.fetchDeps {
      inherit pname version src;
      hash = "sha256-xjctC1GucynVkm2HSlFC7XfocQpHUffQmQ/+Ali8GR8=";
    };

    nativeBuildInputs = [
      cacert
      cargo-tauri
      desktop-file-utils
      gcc
      nodejs
      nodejs.pkgs.node-gyp-build
      node-gyp
      node-pre-gyp
      openssl
      python3
      pkg-config
      pnpm.configHook
      prisma
      stdenv.cc.cc
      wrapGAppsHook3
    ];

    buildInputs =
      [
        glib-networking
        openssl
        stdenv.cc.cc.lib
      ]
      ++ lib.optionals stdenv.hostPlatform.isLinux [
        libayatana-appindicator
        libsoup
        gtk3
        webkitgtk
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin (
        with darwin.apple_sdk.frameworks; [
          AppKit
          CoreServices
          Security
          WebKit
        ]
      );

    env = {
      tauriBundle =
        {
          Linux = "deb";
          Darwin = "app";
        }
        .${stdenv.hostPlatform.uname.system}
        or (throw "No tauri bundle available for ${stdenv.hostPlatform.uname.system}!");

      PRISMA_BINARY_PATH = lib.getExe' prisma "prisma";
      PRISMA_SCHEMA_ENGINE_BINARY = "${prisma-engines}/bin/schema-engine";
      PRISMA_QUERY_ENGINE_BINARY = "${prisma-engines}/bin/query-engine";
      PRISMA_QUERY_ENGINE_LIBRARY = "${lib.getLib prisma-engines}/lib/libquery_engine.node";

      CPPFLAGS = "-I${nodejs}/include/node";

      LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
    };

    preBuild = ''
      # Link Node.js headers so `isolated-vm` can build within the Nix sandbox.
      mkdir -p "$HOME"/.node-gyp/${nodejs.version}
      echo 9 > "$HOME"/.node-gyp/${nodejs.version}/installVersion
      ln -sfv ${nodejs}/include "$HOME"/.node-gyp/${nodejs.version}
      export npm_config_nodedir=${nodejs}

      (cd node_modules/.pnpm/argon2@0.30.3/node_modules/argon2; node-pre-gyp install --prefer-offline --build-from-source --nodedir=${nodejs}/include/node)
      (cd node_modules/.pnpm/bcrypt@5.1.0/node_modules/bcrypt; node-pre-gyp install --prefer-offline --build-from-source --nodedir=${nodejs}/include/node)

      pnpm rebuild --recursive --pending --use-stderr --stream

      echo 'Generating prisma for hoppscotch-backend...'
      (cd packages/hoppscotch-backend; prisma generate)
      echo 'Prisma generated for hoppscotch-backend!'
    '';

    buildPhase = ''
      runHook preBuild

      cp .env.example .env
      cp .env.example .env.development

      echo 'Running graphql-codegen for hoppscotch-selfhost-desktop...'
      (cd packages/hoppscotch-selfhost-desktop; pnpm graphql-codegen --config gql-codegen.yml)
      echo 'graphql-codegen completed for hoppscotch-selfhost-desktop'

      # Equivalent of `pnpm run generate` for this project. We do this so extra
      # args can be added to `pnpm` to get the output to print properly in the
      # event of a failure.
      pnpm run --recursive --use-stderr --stream do-build-prod

      echo 'Building hoppscotch-selfhost-desktop...'
      cd packages/hoppscotch-selfhost-desktop
      pnpm run build
      echo 'Built hoppscotch-selfhost-desktop'

      echo 'Building tauri app...'
      cargo tauri build --bundles "$tauriBundle"
      echo 'Built tauri app'

      runHook postBuild
    '';

    installPhase =
      ''
        runHook preInstall

        cd src-tauri
      ''
      + lib.optionalString stdenv.isDarwin ''
        mkdir -p "$out"/bin
        cp -r target/release/bundle/macos "$out"/Applications
        mv "$out"/Applications/Hoppscotch.app/Contents/MacOS/Hoppscotch "$out"/bin/hoppscotch
        ln -s "$out"/bin/hoppscotch "$out"/Applications/Hoppscotch.app/Contents/MacOS/Hoppscotch
      ''
      + lib.optionalString stdenv.isLinux ''
        cp -r target/release/bundle/"$tauriBundle"/*/data/usr "$out"
        desktop-file-edit \
          --set-comment 'Hoppscotch' \
          --set-key='StartupNotify' --set-value='true' \
          --set-key='Categories' --set-value='Development;' \
          --set-key='Keywords' --set-value='api;rest;' \
          --set-key='StartupWMClass' --set-value='io.hoppscotch.desktop' \
          --add-mime-type='hoppscotch' \
          --add-mime-type='io.hoppscotch.desktop' \
          "$out"/share/applications/hoppscotch.desktop
      ''
      + ''
        runHook postInstall
      '';

    meta = {
      mainProgram = "hoppscotch";
      description = "Open source API development ecosystem";
      longDescription = ''
        Hoppscotch is a lightweight, web-based API development suite. It was built
        from the ground up with ease of use and accessibility in mind providing
        all the functionality needed for API developers with minimalist,
        unobtrusive UI.
      '';
      homepage = "https://hoppscotch.com";
      downloadPage = "https://hoppscotch.com/downloads";
      changelog = "https://hoppscotch.com/changelog";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [matthewpi];
    };
  }
