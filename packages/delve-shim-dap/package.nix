{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "delve-shim-dap";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "zed-industries";
    repo = "delve-shim-dap";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fF19lGZtuT0OMXQfENMgJBlCJ3aD8Z/0Z1wKj/B3xNM=";
  };

  cargoHash = "sha256-UnMqsFicA/6QodKJRi0OiK8JHTytgKgOf3ay6+rirQ8=";

  meta = {
    mainProgram = "delve-shim-dap";
    description = "Shim Debug Adapter for Delve to add support for spawning the terminal in a protocol-compliant way";
    homepage = "https://github.com/zed-industries/delve-shim-dap";
    changelog = "https://github.com/zed-industries/delve-shim-dap/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [matthewpi];
  };
})
