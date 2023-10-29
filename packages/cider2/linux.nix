{
  pname,
  version,
  src,
  meta,
  appimageTools,
  makeWrapper,
}: let
  name = "${pname}-${version}";

  extracted = appimageTools.extractType2 {
    inherit name src;
  };
in
  appimageTools.wrapType2 {
    inherit name src meta;

    extraInstallCommands = ''
      mv "$out/bin/${name}" "$out/bin/${pname}"

      source '${makeWrapper}/nix-support/setup-hook'

      wrapProgram "$out/bin/${pname}" \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
        --add-flags '--disable-seccomp-filter-sandbox'

      install -m 444 -D '${extracted}/usr/share/icons/hicolor/512x512/apps/${pname}.png' \
        "$out/share/icons/hicolor/512x512/apps/${pname}.png"

      install -m 444 -D '${extracted}/${pname}.desktop' \
        "$out/share/applications/${pname}.desktop"
      substituteInPlace "$out/share/applications/${pname}.desktop" \
        --replace 'Exec=AppRun' 'Exec=${pname}'
    '';

    multiArch = false; # no 32bit needed
    extraPkgs = appimageTools.defaultFhsEnvArgs.multiPkgs;
  }
