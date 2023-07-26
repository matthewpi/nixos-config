{
  config,
  lib,
  ...
}: {
  imports = [
    ./default.nix
    ./cli
  ];

  home.homeDirectory = lib.mkDefault "/Users/${config.home.username}";
}
