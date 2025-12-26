{
  callPackage,
  inputs,
  lib,
  moltenvk,
  overrideCC,
  pkgs,
  pkgsCross,
  stdenv,
  wine-mono,
  wrapCCMulti,
  src ? null,
  patches ? [],
  llvmBuild ? true,
  llvmPackages_latest,
}: let
  gccName = "gcc14";

  wineStdenv =
    if llvmBuild
    then llvmPackages_latest.stdenv
    else overrideCC stdenv (wrapCCMulti pkgs.${gccName});

  nixpkgsWineDir = "pkgs/applications/emulators/wine";

  nixpkgs-wine = builtins.path {
    path = inputs.nixpkgs;
    name = "source";
    filter = path: type: let
      wineDir = "${inputs.nixpkgs}/${nixpkgsWineDir}/";
    in (
      (type == "directory" && (lib.hasPrefix path wineDir))
      || (type != "directory" && (lib.hasPrefix wineDir path))
    );
  };

  wineRelease = "unstable";
  sources = (import "${nixpkgs-wine}/${nixpkgsWineDir}/sources.nix" {inherit pkgs;}).${wineRelease};

  base = {
    inherit moltenvk wineRelease;
    buildScript = null;
    configureFlags = ["--disable-tests" "--enable-archs=x86_64,i386" "--with-ffmpeg"];
    geckos = with sources; [gecko32 gecko64];
    mingwGccs = [pkgsCross.mingw32.buildPackages.${gccName} pkgsCross.mingwW64.buildPackages.${gccName}];
    monos = [wine-mono];
    pkgArches = [pkgs];
    platforms = ["x86_64-linux"];
    stdenv = wineStdenv;
    mainProgram = "wine";
    supportFlags = {
      gettextSupport = true;
      fontconfigSupport = true;
      alsaSupport = true;
      openglSupport = true;
      vulkanSupport = true;
      tlsSupport = true;
      cupsSupport = true;
      dbusSupport = true;
      cairoSupport = true;
      cursesSupport = true;
      saneSupport = true;
      pulseaudioSupport = true;
      udevSupport = true;
      xineramaSupport = true;
      sdlSupport = true;
      mingwSupport = true;
      krb5Support = false;
      x11Support = true;
      usbSupport = true;
      gtkSupport = true;
      # We don't need gstreamer with `ffmpeg-full`.
      #
      # NOTE: if gstreamer is enabled, update the `WINE_BIN` (in `./package.nix`)
      # to use the binary name `".wine"`, otherwise winetricks will fail to
      # detect the type of Wine being used.
      gstreamerSupport = false;
      openalSupport = true;
      openclSupport = true;
      odbcSupport = true;
      netapiSupport = true;
      vaSupport = true;
      pcapSupport = true;
      v4lSupport = true;
      gphoto2Support = true;
      embedInstallers = true;
      waylandSupport = true;
      ffmpegSupport = false; # actually true :^)
    };
  };
in
  callPackage "${nixpkgs-wine}/${nixpkgsWineDir}/base.nix" (lib.recursiveUpdate base
    rec {
      pname = "wine-tkg-full";
      version = lib.removeSuffix "\n" (lib.removePrefix "Wine version " (builtins.readFile "${src}/VERSION"));
      inherit src patches;
    })
