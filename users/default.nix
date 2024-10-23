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
    # Use the `nixpkgs.pkgs` instance of nixpkgs and disable per-user `nixpkgs.*`
    # config options.
    #
    # This allows us to avoid having to construct multiple nixpkgs instances
    # and allow us to easily configure overlays and other settings (such as
    # allowUnfree) in one place rather than multiple.
    useGlobalPkgs = true;

    # Allow users to install their own packages.
    useUserPackages = true;

    extraSpecialArgs = {
      inherit flavour inputs isDesktop outputs;
    };
  };

  # Disable dynamic users
  users.mutableUsers = false;
}
