{
  inputs,
  lib,
  pkgs,
  pkgsCross,
  pkgsi686Linux,
  callPackage,
  moltenvk,
  overrideCC,
  wrapCCMulti,
  gcc14,
  stdenv,
  src ? null,
  patches ? [],
}: let
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

  base = let
    sources = (import "${nixpkgs-wine}/${nixpkgsWineDir}/sources.nix" {inherit pkgs;}).unstable;
  in {
    inherit moltenvk;
    buildScript = "${nixpkgs-wine}/${nixpkgsWineDir}/builder-wow.sh";
    configureFlags = ["--disable-tests"];
    geckos = with sources; [gecko32 gecko64];
    mingwGccs = with pkgsCross; [mingw32.buildPackages.gcc14 mingwW64.buildPackages.gcc14];
    monos = with sources; [mono];
    pkgArches = [pkgs pkgsi686Linux];
    platforms = ["x86_64-linux"];
    stdenv = overrideCC stdenv (wrapCCMulti gcc14);
    wineRelease = "unstable";
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
      gstreamerSupport = true;
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
      ffmpegSupport = true;
    };
  };
in
  callPackage "${nixpkgs-wine}/${nixpkgsWineDir}/base.nix" (lib.recursiveUpdate base
    rec {
      pname = "wine-tkg-full";
      version = lib.removeSuffix "\n" (lib.removePrefix "Wine version " (builtins.readFile "${src}/VERSION"));
      inherit src patches;
    })
