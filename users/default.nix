{
  flavour,
  inputs,
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
      inherit flavour inputs outputs;
    };
  };

  # Disable dynamic users
  users.mutableUsers = false;
}
