{
  imports = [
    ./djt.nix
  ];

  nix = {
    distributedBuilds = true;

    # Useful when the builder has a faster internet connection than yours
    extraOptions = ''
      builders-use-substitutes = true
    '';
  };
}
