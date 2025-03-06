{
  pname,
  version,
  src,
  meta,
  appimageTools,
  lib,
  makeWrapper,
}: let
  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

  enableFeatures = [
    "AcceleratedVideoDecoder"
    "AcceleratedVideoDecodeLinuxGL"
    "AcceleratedVideoDecodeLinuxZeroCopyGL"
    "AcceleratedVideoEncoder"
    "Vulkan"
  ];

  flags = [
    "--use-angle=vulkan"
    # "--use-vulkan"
    "--disable-seccomp-filter-sandbox"
    "--enable-accelerated-2d-canvas"
    "--enable-accelerated-mjpeg-decode"
    "--enable-accelerated-video-decode"
    "--enable-features=${lib.concatStringsSep "," enableFeatures}"
    "--enable-gpu-compositing"
    "--enable-gpu-rasterization"
    "--enable-native-gpu-memory-buffers"
    "--enable-zero-copy"
    "--ignore-gpu-blocklist"
  ];
in
  appimageTools.wrapType2 {
    inherit pname version src meta;

    multiArch = false; # no 32bit needed
    extraPkgs = appimageTools.defaultFhsEnvArgs.multiPkgs;

    extraInstallCommands = ''
      source '${makeWrapper}/nix-support/setup-hook'

      wrapProgram "$out"/bin/${meta.mainProgram} \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
        --add-flags '${lib.concatStringsSep " " flags}'

      install -Dm444 '${appimageContents}/usr/share/icons/hicolor/256x256/cider.png' "$out"/share/icons/hicolor/256x256/cider.png
      install -Dm444 '${appimageContents}/Cider.desktop' "$out"/share/applications/cider.desktop
      substituteInPlace "$out"/share/applications/cider.desktop \
        --replace-fail 'Exec=cider' 'Exec=${meta.mainProgram}' \
        --replace-fail 'Exec=Cider' 'Exec=${meta.mainProgram}' \
        --replace-fail 'Actions=[object Object]' 'Actions=PlayPause;Next;Previous'
    '';
  }
