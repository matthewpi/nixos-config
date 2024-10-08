{
  desktop-file-utils,
  hoppscotch-unwrapped,
  lib,
  stdenv,
  symlinkJoin,
  wrapGAppsHook3,
  xdg-utils,
}:
symlinkJoin rec {
  name = "${pname}-${version}";
  pname = "hoppscotch";
  inherit (hoppscotch-unwrapped) version;

  paths = [hoppscotch-unwrapped];

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

  inherit (hoppscotch-unwrapped) meta;
}
