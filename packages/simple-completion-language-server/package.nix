{
  fetchFromGitHub,
  lib,
  rustPlatform,
  withCitation ? true,
}:
rustPlatform.buildRustPackage {
  pname = "simple-completion-language-server";
  version = "0-unstable-2025-05-27";

  src = fetchFromGitHub {
    owner = "estin";
    repo = "simple-completion-language-server";
    rev = "9172fdef34a4e6236485e3293054455d00b5b219";
    hash = "sha256-TZwUqqVH1ajCv84hLrk3s5YHMa+2ZYOkdgK0SLc7VD0=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-L5LuyFy7sd7Ss4wIFp14SpKU+sfLjyASvhyYCYMdxs8=";

  buildFeatures = lib.optional withCitation ["citation"];

  meta = {
    mainProgram = "simple-completion-language-server";
    description = "Language server to enable word completion and snippets for Helix editor";
    homepage = "https://github.com/estin/simple-completion-language-server";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [matthewpi];
  };
}
