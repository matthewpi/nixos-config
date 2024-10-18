{
  flavour,
  inputs,
  isDesktop,
  outputs,
  ...
}: {
  imports = [
    ./matthew.nix
  ];

  # Configure home-manager
  home-manager = {
    useUserPackages = true;

    extraSpecialArgs = {
      inherit flavour inputs isDesktop outputs;
    };
  };

  # Disable dynamic users
  users.mutableUsers = false;
}
