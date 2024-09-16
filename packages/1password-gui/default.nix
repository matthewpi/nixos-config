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
    then "8.10.44"
    else "8.10.46-11.BETA";

  sources = {
    stable = {
      x86_64-linux = {
        url = "https://downloads.1password.com/linux/tar/stable/x86_64/1password-${version}.x64.tar.gz";
        hash = "sha256-O4amN4hOcVHrQLGwfkRsF9Ri08MrHI63lOOnDiOluys=";
      };
      aarch64-linux = {
        url = "https://downloads.1password.com/linux/tar/stable/aarch64/1password-${version}.arm64.tar.gz";
        hash = "sha256-xRfPqr1sGm0NNfYISDcM9mqox3BPbJJ/AkD0YfPIiRM=";
      };
      x86_64-darwin = {
        url = "https://downloads.1password.com/mac/1Password-${version}-x86_64.zip";
        hash = "sha256-/SbU/KyIDC7NfAiGoey8WnJ7WAx3kOK3wf24cT0Cbz8=";
      };
      aarch64-darwin = {
        url = "https://downloads.1password.com/mac/1Password-${version}-aarch64.zip";
        hash = "sha256-K58kLye6Om5FiT5ENqge69YkeHRqv2VcdhwI4ZhAJNM=";
      };
    };
    beta = {
      x86_64-linux = {
        url = "https://downloads.1password.com/linux/tar/beta/x86_64/1password-${version}.x64.tar.gz";
        hash = "sha256-a9YvjyOSMtfGKhFtEizYcV673JFd9fvwFBMo45WdoC4=";
      };
      aarch64-linux = {
        url = "https://downloads.1password.com/linux/tar/beta/aarch64/1password-${version}.arm64.tar.gz";
        hash = "sha256-Syt8Fq28mBK3p1q3796WN/jo8poA2+WbKNt8WAoaC7w=";
      };
      # x86_64-darwin = {
      #   url = "https://downloads.1password.com/mac/1Password-${version}-x86_64.zip";
      #   hash = "";
      # };
      # aarch64-darwin = {
      #   url = "https://downloads.1password.com/mac/1Password-${version}-aarch64.zip";
      #   hash = "";
      # };
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
