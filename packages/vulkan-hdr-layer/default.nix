{
  fetchFromGitHub,
  lib,
  libX11,
  meson,
  ninja,
  pkg-config,
  stdenv,
  vulkan-headers,
  vulkan-loader,
  wayland,
  wayland-scanner,
}:
stdenv.mkDerivation {
  pname = "vulkan-hdr-layer";
  version = "0-unstable-2024-12-27";

  src = fetchFromGitHub {
    owner = "Zamundaaa";
    repo = "VK_hdr_layer";
    rev = "1534ef826bfecf525a6c3154f2e3b52d640a79cf";
    hash = "sha256-LaI7axY+O6MQ/7xdGlTO3ljydFAvqqdZpUI7A+B2Ilo=";
    fetchSubmodules = true;
  };

  depsBuildBuild = [pkg-config];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    libX11
    vulkan-headers
    vulkan-loader
    wayland
  ];

  strictDeps = true;

  meta = {
    description = "Vulkan Wayland HDR WSI Layer";
    homepage = "https://github.com/Zamundaaa/VK_hdr_layer";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [matthewpi];
  };
}
