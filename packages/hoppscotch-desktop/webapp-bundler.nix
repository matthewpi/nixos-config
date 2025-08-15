{
  hoppscotch,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hoppscotch-webapp-bundler";
  inherit (hoppscotch) version src;

  sourceRoot = "${finalAttrs.src.name}/packages/hoppscotch-desktop/crates/webapp-bundler";
  cargoHash = "sha256-6VGZs52TCHal0GX4BwzhaISWRPlPVmH9+m/K9vpcM0Y=";

  meta.mainProgram = "webapp-bundler";
})
