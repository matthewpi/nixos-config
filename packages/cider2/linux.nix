{
  pname,
  version,
  src,
  meta,
  appimageTools,
  makeWrapper,
}: let
  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
  appimageTools.wrapType2 {
    inherit pname version src meta;

    multiArch = false; # no 32bit needed
    extraPkgs = appimageTools.defaultFhsEnvArgs.multiPkgs;

    extraInstallCommands = ''
      source '${makeWrapper}/nix-support/setup-hook'

      wrapProgram "$out"/bin/${meta.mainProgram} \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
        --add-flags '--disable-seccomp-filter-sandbox --ignore-gpu-blocklist --enable-gpu-rasterization --enable-gpu --enable-features=Vulkan,UseSkiaRenderer,VaapiVideoDecoder,CanvasOopRasterization,VaapiVideoEncoder,RawDraw --disable-features=UseChromeOSDirectVideoDecoder --enable-zero-copy --enable-oop-rasterization --enable-raw-draw --enable-accelerated-mjpeg-decode --enable-accelerated-video --enable-native-gpu-memory-buffers'

      install -Dm444 '${appimageContents}/usr/share/icons/hicolor/256x256/cider.png' "$out"/share/icons/hicolor/256x256/cider.png
      install -Dm444 '${appimageContents}/Cider.desktop' "$out"/share/applications/cider.desktop
      substituteInPlace "$out"/share/applications/cider.desktop \
        --replace-fail 'Exec=cider' 'Exec=${meta.mainProgram}' \
        --replace-fail 'Exec=Cider' 'Exec=${meta.mainProgram}' \
        --replace-fail 'Actions=[object Object]' 'Actions=PlayPause;Next;Previous'
    '';
  }
