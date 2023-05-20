{inputs, ...}: {
  imports = [
    ./amd-ryzen
    ./catppuccin
    ./desktop
    ./gnome
    ./persistence
    ./podman
    ./system
    ./virtualisation
  ];

  flake.nixosModules = {
    agenix = inputs.agenix.nixosModules.default;
    bootspec-secureboot = inputs.bootspec-secureboot.nixosModules.bootspec-secureboot;
    home-manager = inputs.home-manager.nixosModules.home-manager;
    impermanence = inputs.impermanence.nixosModules.impermanence;
  };
}
