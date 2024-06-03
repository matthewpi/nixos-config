{
  stdenv,
  callPackage,
  channel ? "stable",
  fetchurl,
  lib,
  # This is only relevant for Linux, so we need to pass it through
  polkitPolicyOwners ? [],
}: let
  pname = "1password";
  version =
    if channel == "stable"
    then "8.10.33"
    else "8.10.34-39.BETA";

  sources = {
    stable = {
      x86_64-linux = {
        url = "https://downloads.1password.com/linux/tar/stable/x86_64/1password-${version}.x64.tar.gz";
        hash = "sha256-njSvRi/sA7l5+XxfCpv3FY9SmCv5oPix9l2EZewZg1M=";
      };
      aarch64-linux = {
        url = "https://downloads.1password.com/linux/tar/stable/aarch64/1password-${version}.arm64.tar.gz";
        hash = "sha256-g4RMTlBQvJQaPD/6scYjpe7NWrL6gkjvh5b9LubTWaE=";
      };
      x86_64-darwin = {
        url = "https://downloads.1password.com/mac/1Password-${version}-x86_64.zip";
        hash = "sha256-YzAYMk3SR+paIQYAZCx840u/k77soy17F15owpqRAU0=";
      };
      aarch64-darwin = {
        url = "https://downloads.1password.com/mac/1Password-${version}-aarch64.zip";
        hash = "sha256-FlJnPMIv7mWh3dSACq01f16mB9EkVD2LOg3IIpvjwdY=";
      };
    };
    beta = {
      x86_64-linux = {
        url = "https://downloads.1password.com/linux/tar/beta/x86_64/1password-${version}.x64.tar.gz";
        hash = "sha256-XcyUhyhqqLCcCuj9XOFW1cWHmHtC7Brxhi6gZW/N0qo=";
      };
      aarch64-linux = {
        url = "https://downloads.1password.com/linux/tar/beta/aarch64/1password-${version}.arm64.tar.gz";
        hash = "sha256-001Ns2Sq0FJHuuv1Www841Cihbx8ylIwAi26SrAMNgQ=";
      };
      x86_64-darwin = {
        url = "https://downloads.1password.com/mac/1Password-${version}-x86_64.zip";
        hash = "sha256-K5xFu7Sodo3cATfS63/Qd7GihollE6Gi7W0Xn0jYPjg=";
      };
      aarch64-darwin = {
        url = "https://downloads.1password.com/mac/1Password-${version}-aarch64.zip";
        hash = "sha256-TtqmI0pJ8y+i7lLjS27S1+A7j/FRnS/tNrUCKFZ9cvc=";
      };
    };
  };

  src = fetchurl {
    inherit (sources.${channel}.${stdenv.system} or (throw "unsupported system ${stdenv.hostPlatform.system}")) url hash;
  };

  meta = with lib; {
    description = "Multi-platform password manager";
    homepage = "https://1password.com/";
    sourceProvenance = with sourceTypes; [binaryNativeCode];
    license = licenses.unfree;
    maintainers = with maintainers; [timstott savannidgerinel sebtm];
    platforms = builtins.attrNames sources.${channel};
    mainProgram = "1password";
  };
in
  if stdenv.isDarwin
  then callPackage ./darwin.nix {inherit pname version src meta;}
  else callPackage ./linux.nix {inherit pname version src meta polkitPolicyOwners;}
