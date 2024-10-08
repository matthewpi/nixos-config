{
  pname,
  version,
  src,
  meta,
  appimageTools,
  makeWrapper,
}: let
  name = "${pname}-${version}";

  appimageContents = appimageTools.extractType2 {
    inherit name src;
  };
in
  appimageTools.wrapType2 {
    inherit name src meta;

    multiArch = false; # no 32bit needed
    extraPkgs = appimageTools.defaultFhsEnvArgs.multiPkgs;

    extraInstallCommands = ''
      mv "$out"/bin/${name} "$out"/bin/cider

      source '${makeWrapper}/nix-support/setup-hook'

      wrapProgram "$out"/bin/cider \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
        --add-flags '--disable-seccomp-filter-sandbox --ignore-gpu-blocklist --enable-gpu-rasterization --enable-gpu --enable-features=Vulkan,UseSkiaRenderer,VaapiVideoDecoder,CanvasOopRasterization,VaapiVideoEncoder,RawDraw --disable-features=UseChromeOSDirectVideoDecoder --enable-zero-copy --enable-oop-rasterization --enable-raw-draw --enable-accelerated-mjpeg-decode --enable-accelerated-video --enable-native-gpu-memory-buffers'

      install -Dm444 '${appimageContents}/usr/share/icons/hicolor/512x512/apps/cider.png' "$out"/share/icons/hicolor/512x512/apps/cider.png
      install -Dm444 '${appimageContents}/cider.desktop' "$out"/share/applications/cider.desktop
      substituteInPlace "$out"/share/applications/cider.desktop \
        --replace-fail 'Exec=AppRun' 'Exec=cider'
    '';
  }
