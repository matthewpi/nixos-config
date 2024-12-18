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
    then "8.10.56"
    else "8.10.56-22.BETA";

  sources = {
    stable = {
      x86_64-linux = {
        url = "https://downloads.1password.com/linux/tar/stable/x86_64/1password-${version}.x64.tar.gz";
        hash = "sha256-vJf6V3NwEAIUi0aq4ktVOrhDWTSTeeFi3j/kvdMp0e4=";
      };
      aarch64-linux = {
        url = "https://downloads.1password.com/linux/tar/stable/aarch64/1password-${version}.arm64.tar.gz";
        hash = "sha256-0aBZ97D2EG3TOpghrKdYZteA3f2IxjlcHzCkjvLtFkI=";
      };
      x86_64-darwin = {
        url = "https://downloads.1password.com/mac/1Password-${version}-x86_64.zip";
        hash = "sha256-u5EMt+xEu5EDDs2vTm/oF3FF7HbsnBVFKSAR8+ThUOY=";
      };
      aarch64-darwin = {
        url = "https://downloads.1password.com/mac/1Password-${version}-aarch64.zip";
        hash = "sha256-byu8SW/GVvKBDN02BblziRzo4QG00k7tuC5Bb5BpqtU=";
      };
    };
    beta = {
      x86_64-linux = {
        url = "https://downloads.1password.com/linux/tar/beta/x86_64/1password-${version}.x64.tar.gz";
        hash = "sha256-FkFiPi2Uvei9ur3fI+fgXSI1MJB9CHCdKBCtRamD5T0=";
      };
      aarch64-linux = {
        url = "https://downloads.1password.com/linux/tar/beta/aarch64/1password-${version}.arm64.tar.gz";
        hash = "sha256-RxcdDm6hu2UQEgnYvi0tuVEaaTUaZYLNtOiS8WXxNu8=";
      };
      x86_64-darwin = {
        url = "https://downloads.1password.com/mac/1Password-${version}-x86_64.zip";
        hash = "sha256-izx16EutmKH3BhC2WfaA+DOOQ5NbCxs/eBSNTeaAtU0=";
      };
      aarch64-darwin = {
        url = "https://downloads.1password.com/mac/1Password-${version}-aarch64.zip";
        hash = "sha256-pkPEdhXf+Kb4cm1euYAUrZlslHjjMuKkATODxORBOyg=";
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
