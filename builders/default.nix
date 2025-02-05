{
  imports = [
    ./blahaj.nix
    # ./djt.nix
  ];

  nix.distributedBuilds = true;

  # Useful when the builder has a faster internet connection than yours
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
}
