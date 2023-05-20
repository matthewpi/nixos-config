{
  flake.nixosModules.virtualisation = {...}: {
    imports = [
      ./libvirtd.nix
    ];
  };
}
