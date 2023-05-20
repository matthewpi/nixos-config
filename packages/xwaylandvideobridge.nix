{
  cmake,
  extra-cmake-modules,
  fetchFromGitLab,
  lib,
  libsForQt5,
  pkg-config,
  stdenv,
  qt5,
  wrapQtAppsHook,
}:
stdenv.mkDerivation rec {
  pname = "xwaylandvideobridge";
  version = "unstable-2023-05-18";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "system";
    repo = "xwaylandvideobridge";
    rev = "17c8de642a61066cf597b40d0d26bac2855334ce";
    hash = "sha256-db2JZ7oOYVNpV96IBQgRJlNe4B9lISFJjEVxocfiFUU=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    qt5.qtbase
    qt5.qtquickcontrols2
    qt5.qtx11extras
    libsForQt5.kdelibs4support
    (libsForQt5.kpipewire.overrideAttrs (_oldAttrs: {
      version = "unstable-2023-03-28";

      src = fetchFromGitLab {
        domain = "invent.kde.org";
        owner = "plasma";
        repo = "kpipewire";
        rev = "ed99b94be40bd8c5b7b2a2f17d0622f11b2ab7fb";
        hash = "sha256-KhmhlH7gaFGrvPaB3voQ57CKutnw5DlLOz7gy/3Mzms=";
      };
    }))
  ];

  # dontWrapQtApps = true;

  meta = {
    description = "A tool to make it easy to stream wayland windows and screens to Xwayland applicatons that don't have native pipewire support.";
    homepage = "https://invent.kde.org/system/xwaylandvideobridge";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [matthewpi];
  };
}
