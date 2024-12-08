{
  callPackage,
  cmake,
  copyDesktopItems,
  fetchurl,
  fetchFromGitHub,
  fetchNpmDeps,
  lib,
  libX11,
  libxcb,
  libxkbcommon,
  makeDesktopItem,
  nodejs,
  npmHooks,
  openssl,
  pkg-config,
  protobuf,
  rustPlatform,
  stdenv,
  vulkan-loader,
  wayland,
  writeText,
}: let
  denoTypeDeclarations = fetchurl {
    # https://github.com/project-gauntlet/gauntlet/blob/v11/js/deno/generator/index.ts#L4
    url = "https://github.com/denoland/deno/releases/download/v1.36.4/lib.deno.d.ts";
    hash = "sha256-faimw0TezsJVH8yYUJYS5BZ6FNJ3Ly2doru3AFuC68k=";
  };

  generator = writeText "index.ts" ''
    import { existsSync, mkdirSync, writeFileSync, readFileSync } from "node:fs";

    const content = readFileSync('${denoTypeDeclarations}', 'utf8');

    const fixedContent = content.replaceAll(/\/\/\/ <reference lib="deno\..*" \/>/g, "")

    const distDir = "./dist";
    if (!existsSync(distDir)) {
        mkdirSync(distDir);
    }

    writeFileSync(`''${distDir}/lib.deno.d.ts`, fixedContent)
  '';
in
  rustPlatform.buildRustPackage rec {
    pname = "gauntlet";
    version = "11";

    src = fetchFromGitHub {
      owner = "project-gauntlet";
      repo = "gauntlet";
      rev = "refs/tags/v${version}";
      hash = "sha256-6QsIBu5luQdfqVdwPM0HBLuS4v9diMBfSHDJ6FP1l24=";
      fetchSubmodules = true;
    };

    cargoLock = {
      lockFile = ./Cargo.lock;
      outputHashes = {
        "iced-0.12.3" = "sha256-EIapf+bLj0tw4rmEQELzM+YKR4AJ9IYYPmuSNqw32Qk=";
        "iced_aw-0.8.0" = "sha256-nvK4Djm8qGskfAh5CDmRppQye6Dq99an+72Vjov63zQ=";
        "iced_table-0.12.0" = "sha256-5vUUwPIChA91CdLI8zxS+cm+CLW6GW+zb26492aH0Fs=";
        "smithay-client-toolkit-0.18.0" = "sha256-2WbDKlSGiyVmi7blNBr2Aih9FfF2dq/bny57hoA4BrE=";
      };
    };

    npmDeps = fetchNpmDeps {
      name = "${pname}-npm-deps-${version}";
      inherit src;
      hash = "sha256-ZaVtPKunssM2PFgvy3dxZ5+RCWZGtVxVLXASJemFv50=";
    };

    # TODO: check if this is necessary.
    doCheck = false;

    nativeBuildInputs = [
      cmake
      copyDesktopItems
      nodejs
      npmHooks.npmConfigHook
      pkg-config
      protobuf
    ];

    buildInputs =
      [
        openssl
      ]
      ++ lib.optionals stdenv.hostPlatform.isLinux [
        libX11
        libxcb
        libxkbcommon
      ];

    buildFeatures = ["release"];

    OPENSSL_NO_VENDOR = 1;

    # The v8 package will try to download a `librusty_v8.a` release at build time to our read-only filesystem
    # To avoid this we pre-download the file and export it via RUSTY_V8_ARCHIVE
    RUSTY_V8_ARCHIVE = callPackage ./librusty_v8.nix {};

    preBuild = ''
      rm -f js/deno/generator/index.ts
      ln -s ${generator} js/deno/generator/index.ts

      patchShebangs node_modules/@project-gauntlet/tools/bin/main.js

      npm run build
    '';

    postInstall = ''
      install -Dm644 assets/linux/icon_256.png "$out"/share/icons/hicolor/256x256/apps/gauntlet.png
    '';

    # Add required but not explicitly requested libraries
    postFixup = lib.optional stdenv.hostPlatform.isLinux (let
      libraryPath = lib.makeLibraryPath [
        libxkbcommon
        vulkan-loader
        wayland
      ];
    in ''
      patchelf --add-rpath '${libraryPath}' "$out"/bin/gauntlet
    '');

    desktopItems = [
      (makeDesktopItem {
        name = "gauntlet";
        desktopName = "Gauntlet";
        exec = "gauntlet";
        icon = "gauntlet";
        comment = "App Launcher";
        noDisplay = true;
        terminal = false;
        actions.settings = {
          name = "Gauntlet Settings";
          exec = "gauntlet settings";
        };
      })
    ];

    meta = {
      mainProgram = "gauntlet";
      description = "";
      homepage = "https://github.com/project-gauntlet/gauntlet";
      maintainers = with lib.maintainers; [matthewpi];
      license = lib.licenses.mpl20;
      # TODO: darwin
      platforms = lib.platforms.linux;
    };
  }
