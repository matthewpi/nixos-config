{
  fetchFromGitHub,
  lib,
  rustPlatform,
  withCitation ? true,
}:
rustPlatform.buildRustPackage {
  pname = "simple-completion-language-server";
  version = "0-unstable-2025-06-12";

  src = fetchFromGitHub {
    owner = "estin";
    repo = "simple-completion-language-server";
    rev = "2ce0ccac9730b14933c7cec0718d602f107b5769";
    hash = "sha256-WxfZOxqIwI9q3PMlgMHrVbs0n/2hXF5kdYcLimaVQzM=";
  };

  cargoHash = "sha256-+HAwmV2trs4lPxSlCCGa/dQAVDflILznXE7T+/iXEy0=";

  buildFeatures = lib.optional withCitation ["citation"];

  meta = {
    mainProgram = "simple-completion-language-server";
    description = "Language server to enable word completion and snippets for Helix editor";
    homepage = "https://github.com/estin/simple-completion-language-server";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [matthewpi];
  };
}
