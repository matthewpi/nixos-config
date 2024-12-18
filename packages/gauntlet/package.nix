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
  gtk3,
  makeDesktopItem,
  makeWrapper,
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
    url = "https://github.com/denoland/deno/releases/download/v2.1.1/lib.deno.d.ts";
    hash = "sha256-MvaKkXl8cNoWUmtwWqjuXuYmKH1rRHtLitgGcomyC2o=";
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
    version = "unstable-2024-12-18";

    src = fetchFromGitHub {
      owner = "project-gauntlet";
      repo = "gauntlet";
      rev = "0b67e67d0bc35faa99dc172309cf2fafb0d9a8dd";
      hash = "sha256-c/0ZdpabxHxy4bCYSjobnzT5haFCYRPTL/gpkASiY3I=";
      fetchSubmodules = true;
    };

    # Replace the Cargo.lock in the repo with the one we have. This is necessary
    # because we had to remove a duplicate dependency. Additionally, make it
    # writable as it seems something tries to modify it during the build, not
    # exactly sure why as modifying it shouldn't change anything (at least when
    # building with Nix).
    postPatch = ''
      rm Cargo.lock
      cp ${./Cargo.lock} Cargo.lock
      chmod 644 Cargo.lock
    '';

    cargoLock = {
      lockFile = ./Cargo.lock;
      outputHashes = {
        "dpi-0.1.1" = "sha256-XCvMIMr9zne6qQS3H4cKP+YoZnCC3n3yeMxWiE6Ne/I=";
        "glyphon-0.5.0" = "sha256-VgeV/5nYQwzYQWN8/e/kCljqv3vB7McJb4aA6OhhrOI=";
        "iced-0.13.99" = "sha256-U589ojs2xShhyI3HZue/e0QrRPu4Geq6/jmKrYah8bU=";
        "iced_aw-0.11.99" = "sha256-BVyHxj4H0r0MUCeMNzPTj2wBdnqatjyTOIGnPYbIZgg=";
        "iced_fonts-0.1.99" = "sha256-Foq/f/Qjjm58yE1QLukHXxnBUB0JBMiHj6wEZuwy+Bc=";
        "iced_layershell-0.13.99" = "sha256-lYRRcDA6XZVBBEiDsGnJMJJFz3JTS4K2vIcbvc18pMw=";
        "iced_table-0.13.99" = "sha256-37yrSysSUI3dr3bTTJ5RxRpsT92LYPyf8YFirQJyHq0=";
      };
    };
    # TODO: use this once we don't need to override the Cargo.lock.
    # useFetchCargoVendor = true;
    # cargoHash = lib.fakeHash;

    npmDeps = fetchNpmDeps {
      name = "${pname}-npm-deps-${version}";
      inherit src;
      hash = "sha256-ncrEs3NJLPrSh8SMlkHfUZeu3cW7oTDbuSUOS2nlwoI=";
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
        makeWrapper
      ];

    buildFeatures = ["release"];

    env = {
      OPENSSL_NO_VENDOR = 1;

      # The v8 package will try to download a `librusty_v8.a` release at build time to our read-only filesystem
      # To avoid this we pre-download the file and export it via RUSTY_V8_ARCHIVE
      RUSTY_V8_ARCHIVE = callPackage ./librusty_v8.nix {};
    };

    preBuild = ''
      ln -sf ${generator} js/deno/generator/index.ts

      patchShebangs node_modules/@project-gauntlet/tools/bin/main.js

      npm run build
    '';

    postInstall = ''
      install -Dm644 assets/linux/icon_256.png "$out"/share/icons/hicolor/256x256/apps/gauntlet.png
    '';

    # Add required but not explicitly requested libraries
    postFixup = lib.optionalString stdenv.hostPlatform.isLinux (let
      libraryPath = lib.makeLibraryPath [
        libxkbcommon
        vulkan-loader
        wayland
      ];
    in ''
      patchelf --add-rpath '${libraryPath}' "$out"/bin/gauntlet
      wrapProgram "$out"/bin/gauntlet \
        --suffix PATH : ${lib.makeBinPath [gtk3]}
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
