{
  cargo-tauri,
  darwin,
  desktop-file-utils,
  glib-networking,
  hoppscotch,
  hoppscotch-webapp-bundler,
  jq,
  lib,
  libsoup_3,
  moreutils,
  nodejs,
  openssl,
  pkg-config,
  pnpm_10,
  rustPlatform,
  stdenv,
  webkitgtk_4_1,
  wrapGAppsHook4,
  xdg-utils,
}:
rustPlatform.buildRustPackage {
  pname = "hoppscotch-desktop";
  inherit (hoppscotch) version pnpmDeps;
  src = hoppscotch;

  cargoRoot = "packages/hoppscotch-desktop/src-tauri";
  cargoHash = "sha256-4vYzgCLroD2N2PP6GxUoBpwjKbUzYz+LuF9YnePn+bg=";
  useFetchCargoVendor = true;
  buildAndTestSubdir = "packages/hoppscotch-desktop/src-tauri";

  nativeBuildInputs = [
    cargo-tauri.hook
    desktop-file-utils
    nodejs
    pnpm_10.configHook
    pkg-config
    wrapGAppsHook4

    hoppscotch-webapp-bundler
    jq
    moreutils # for `sponge`
  ];

  # Disable updater endpoints and artifacts. We do this for two reasons:
  #
  # 1. We are in nixpkgs, users cannot just update applications like they do on
  #    other linux distros or operating systems.
  #
  # 2. Having these options enabled require us to provide signing keys for the
  #    update artifacts which we don't have.
  postPatch = ''
    jq '.plugins.updater.endpoints = [] | .bundle.createUpdaterArtifacts = false' "$cargoRoot"/tauri.conf.json | sponge "$cargoRoot"/tauri.conf.json
  '';

  preBuild = ''
    # Setup environment
    pnpm install --dir packages/hoppscotch-desktop

    # Build web app
    pnpm install --dir packages/hoppscotch-selfhost-web
    pnpm --dir packages/hoppscotch-selfhost-web generate

    # Run webapp-bundler
    webapp-bundler \
      --input packages/hoppscotch-selfhost-web/dist \
      --output packages/hoppscotch-desktop/bundle.zip \
      --manifest packages/hoppscotch-desktop/manifest.json
  '';

  buildInputs =
    [
      openssl
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      glib-networking
      libsoup_3
      webkitgtk_4_1
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
    # Needed to get openssl-sys to use pkg-config.
    OPENSSL_NO_VENDOR = 1;
    OPENSSL_LIB_DIR = "${lib.getLib openssl}/lib";
    OPENSSL_DIR = lib.getDev openssl;
  };

  postInstall =
    lib.optionalString stdenv.isDarwin ''
      ln -s "$out"/Applications/Hoppscotch.app/Contents/MacOS/Hoppscotch "$out"/bin/hoppscotch
    ''
    + lib.optionalString stdenv.isLinux ''
      mv "$out"/share/applications/Hoppscotch.desktop "$out"/share/applications/hoppscotch.desktop

      desktop-file-edit \
        --set-comment 'Open-source API development ecosystem' \
        --set-key='StartupNotify' --set-value='true' \
        --set-key='Categories' --set-value='Development;' \
        --set-key='Keywords' --set-value='api;rest;' \
        --set-key='StartupWMClass' --set-value='io.hoppscotch.desktop' \
        --add-mime-type='x-scheme-handler/hoppscotch' \
        --add-mime-type='x-scheme-handler/io.hoppscotch.desktop' \
        "$out"/share/applications/hoppscotch.desktop
    '';

  preFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    gappsWrapperArgs+=(
      --prefix PATH : "${lib.makeBinPath [desktop-file-utils xdg-utils]}"
    )
  '';

  meta =
    hoppscotch.meta
    // {
      mainProgram = "hoppscotch-desktop";
    };
}
