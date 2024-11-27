{
  applyPatches,
  fetchFromGitHub,
  lib,
  openssl,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "simple-completion-language-server";
  version = "0.1.1";

  # We need to use `applyPatches` here since our patch modifies the `Cargo.lock` file.
  # `cargoHash` seems to use `src` directly without applying `patches`.
  src = applyPatches {
    src = fetchFromGitHub {
      owner = "zed-industries";
      repo = "simple-completion-language-server";
      rev = "refs/tags/v${version}";
      hash = "sha256-1AeBdUu+NMkPmHkoZpcJGKpAqMe0SPjvuLuS93CxoRg=";
    };
    patches = [
      ./0001-cargo-update.patch
    ];
  };

  cargoHash = "sha256-PhCAD1A18DKyg69TDTjHAbgD3i5cIiWE3i8smCTbkh8=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  meta = {
    mainProgram = "simple-completion-language-server";
    description = "Language server to enable word completion and snippets";
    homepage = "https://github.com/zed-industries/simple-completion-language-server/";
    maintainers = with lib.maintainers; [matthewpi];
    license = lib.licenses.mit;
  };
}
