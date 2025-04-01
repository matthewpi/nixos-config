{
  cargo-tauri_1,
  darwin,
  desktop-file-utils,
  hoppscotch,
  glib-networking,
  gtk3,
  lib,
  libsoup_2_4,
  nodejs,
  openssl,
  pkg-config,
  pnpm_10,
  rustPlatform,
  stdenv,
  webkitgtk_4_0,
  wrapGAppsHook3,
  xdg-utils,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hoppscotch-desktop";
  inherit (hoppscotch) version pnpmDeps;

  src = hoppscotch;

  cargoRoot = "packages/hoppscotch-selfhost-desktop/src-tauri";
  cargoHash = "sha256-mOBMU9+bcicQYkpOvRvrv4O8pN/FZq7rrbzPs6HT3SU=";
  useFetchCargoVendor = true;
  buildAndTestSubdir = finalAttrs.cargoRoot;

  nativeBuildInputs = [
    cargo-tauri_1.hook

    nodejs
    pnpm_10.configHook

    pkg-config
    wrapGAppsHook3

    desktop-file-utils
  ];

  buildInputs =
    [
      openssl
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      glib-networking
      gtk3
      libsoup_2_4
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
      mainProgram = "hoppscotch";
    };
})
