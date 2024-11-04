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
    then "8.10.50"
    else "8.10.52-14.BETA";

  sources = {
    stable = {
      x86_64-linux = {
        url = "https://downloads.1password.com/linux/tar/stable/x86_64/1password-${version}.x64.tar.gz";
        hash = "sha256-XLEiOiYI+hXlNNotb83eWtJ42oZ18osQRzytZU7eHnE=";
      };
      aarch64-linux = {
        url = "https://downloads.1password.com/linux/tar/stable/aarch64/1password-${version}.arm64.tar.gz";
        hash = "sha256-Yg8How/VFx7QhzuliU84trMp7tyf+w0scR75UP46Nc8=";
      };
      x86_64-darwin = {
        url = "https://downloads.1password.com/mac/1Password-${version}-x86_64.zip";
        hash = "sha256-h4UyzQuKAhUGcxoLNZaMEHuSx5JG5iPxOcCOnCWq028=";
      };
      aarch64-darwin = {
        url = "https://downloads.1password.com/mac/1Password-${version}-aarch64.zip";
        hash = "sha256-KdFWAQrYKGyMHiiInzD8zGras+oePOxjxKzpUr4xnC8=";
      };
    };
    beta = {
      x86_64-linux = {
        url = "https://downloads.1password.com/linux/tar/beta/x86_64/1password-${version}.x64.tar.gz";
        hash = "sha256-K2rRsxlq5K6aNQ7/4arMCwi0FNhLH0hFPJ//l0mDzyE=";
      };
      aarch64-linux = {
        url = "https://downloads.1password.com/linux/tar/beta/aarch64/1password-${version}.arm64.tar.gz";
        hash = "sha256-moXNO0Co5vQydQLQA12CmlDqUlwBTNWS0J/ZVwxK2J8=";
      };
      x86_64-darwin = {
        url = "https://downloads.1password.com/mac/1Password-${version}-x86_64.zip";
        hash = "sha256-kCKVtlLCKji7OFBcB82DcNOJKcrIwgkB/ko7HbhFpBI=";
      };
      aarch64-darwin = {
        url = "https://downloads.1password.com/mac/1Password-${version}-aarch64.zip";
        hash = "sha256-H/Dz1IKAKm1egzQPucbXpC+cgMb/OL0LAYFhImDiEwM=";
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
