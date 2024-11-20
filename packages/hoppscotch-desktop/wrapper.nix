{
  desktop-file-utils,
  hoppscotch-desktop-unwrapped,
  lib,
  stdenv,
  symlinkJoin,
  wrapGAppsHook3,
  xdg-utils,
}:
symlinkJoin rec {
  name = "${pname}-${version}";
  pname = "hoppscotch-desktop";
  inherit (hoppscotch-desktop-unwrapped) version;

  paths = [hoppscotch-desktop-unwrapped];

  nativeBuildInputs = [
    wrapGAppsHook3
  ];

  postBuild = ''
    gappsWrapperArgs+=(
      ${lib.optionalString stdenv.hostPlatform.isLinux ''
      --prefix PATH : ${lib.makeBinPath [desktop-file-utils xdg-utils]}
    ''}
    )

    wrapGAppsHook
  '';

  inherit (hoppscotch-desktop-unwrapped) meta;
}
