{
  cargo-tauri,
  darwin,
  desktop-file-utils,
  hoppscotch,
  glib-networking,
  gtk3,
  lib,
  libayatana-appindicator,
  libsoup,
  nodejs,
  openssl,
  perl,
  pkg-config,
  pnpm_9,
  rustPlatform,
  stdenv,
  webkitgtk_4_0,
}:
rustPlatform.buildRustPackage {
  pname = "hoppscotch-desktop-unwrapped";
  inherit (hoppscotch) version;

  src = hoppscotch;

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "curl-0.4.47" = "sha256-qC4pZxKhQqKXPhid1OYhX/Fx6buFUMHLwySV0C0GhIo=";
      "curl-sys-0.4.77+curl-8.10.1" = lib.fakeHash;
      "tauri-plugin-deep-link-0.1.2" = "sha256-RlMTfUTcM2FAuQ5GNyUrtQK0WZ+kBk+FGzTuSAVdf0c=";
      "tauri-plugin-store-0.0.0" = "sha256-rWk9Qz1XmByqPRIgR+f12743uYvnEGTHno9RrxmT8JE=";
    };
  };
  cargoRoot = "packages/hoppscotch-selfhost-desktop/src-tauri";

  # could not find `Cargo.toml` in `/build/source` or any parent directory.
  doCheck = false;

  nativeBuildInputs = [
    cargo-tauri
    desktop-file-utils
    nodejs
    perl
    pkg-config
    pnpm_9
    stdenv.cc.cc
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
      webkitgtk_4_0
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
        Darwin = "app";
        Linux = "deb";
      }
      .${stdenv.hostPlatform.uname.system}
      or (throw "No tauri bundle available for ${stdenv.hostPlatform.uname.system}!");
  };

  buildPhase = ''
    runHook preBuild

    cd "$cargoRoot"

    echo 'Building hoppscotch-selfhost-desktop Tauri...'
    pnpm tauri build --bundles "$tauriBundle"
    echo 'Built hoppscotch-selfhost-desktop Tauri'

    runHook postBuild
  '';

  installPhase =
    ''
      runHook preInstall
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

  meta =
    hoppscotch.meta
    // {
      mainProgram = "hoppscotch";
    };
}
