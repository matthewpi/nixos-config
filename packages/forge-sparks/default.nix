{
  appstream-glib,
  blueprint-compiler,
  desktop-file-utils,
  fetchFromGitHub,
  gjs,
  gobject-introspection,
  gtk4,
  lib,
  libportal-gtk4,
  libadwaita,
  libsecret,
  libsoup,
  meson,
  ninja,
  pkg-config,
  stdenv,
  wrapGAppsHook4,
}:
stdenv.mkDerivation rec {
  pname = "forge-sparks";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "rafaelmardojai";
    repo = "forge-sparks";
    rev = version;
    hash = "sha256-kUvUAJLCqIQpjm8RzAZaHVkdDCD9uKSQz9cYN60xS+4=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    appstream-glib
    blueprint-compiler
    desktop-file-utils
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gjs
    gtk4
    libadwaita
    libportal-gtk4
    libsecret
    libsoup
  ];

  postPatch = ''
    # /usr/bin/env is not accessible in build environment
    substituteInPlace troll/gjspack/bin/gjspack --replace "/usr/bin/env -S gjs" "${gjs}/bin/gjs"
  '';

  preFixup = ''
    # https://github.com/NixOS/nixpkgs/issues/31168#issuecomment-341793501
    sed -e '2iimports.package._findEffectiveEntryPointName = () => "com.mardojai.ForgeSparks";' \
      -i $out/bin/forge-sparks

    gappsWrapperArgs+=(--prefix PATH : $out/bin)
  '';

  meta = with lib; {
    mainProgram = "forge-sparks";
    description = "Simple notifier app with support for Github, Gitea and Forgejo";
    homepage = "https://apps.gnome.org/ForgeSparks/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [matthewpi];
    platforms = lib.platforms.linux;
  };
}
