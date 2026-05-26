{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "delve-shim-dap";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "zed-industries";
    repo = "delve-shim-dap";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CtE/2bjnSjeLjbQK/UZQVndmmqLUyzfOcZZCx505PAw=";
  };

  cargoHash = "sha256-IkB85k7kusPL4WCmwUvB3cJ2mTo8J2OUHmClLYFzGao=";

  meta = {
    mainProgram = "delve-shim-dap";
    description = "Shim Debug Adapter for Delve to add support for spawning the terminal in a protocol-compliant way";
    homepage = "https://github.com/zed-industries/delve-shim-dap";
    changelog = "https://github.com/zed-industries/delve-shim-dap/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [matthewpi];
  };
})
