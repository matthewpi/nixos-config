{
  fetchFromGitHub,
  lib,
  openssl,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "package-version-server";
  version = "0.0.6";

  src = fetchFromGitHub {
    owner = "zed-industries";
    repo = "package-version-server";
    rev = "refs/tags/v${version}";
    hash = "sha256-09d87LswAQ+wcyX9EFmsFkak4Evg50cqb3T+3b8/G9k=";
  };

  patches = [
    ./0001-fix-ParseResult-does-not-implement-Debug-build-error.patch
  ];

  cargoHash = "sha256-5Hxu2XIFqHjZD0tNdEz624HQNsvM5XGeW8F9+YenM9E=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  meta = {
    mainProgram = "package-version-server";
    description = "Language server that handles hover information in package.json files";
    homepage = "https://github.com/zed-industries/package-version-server/";
    maintainers = with lib.maintainers; [matthewpi];
    license = lib.licenses.mit;
  };
}
