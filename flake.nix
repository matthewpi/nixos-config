{
  description = "Matthew's NixOS Configurations";

  inputs = {
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        darwin.follows = "darwin";
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
    };

    bootspec-secureboot = {
      url = "github:DeterminateSystems/bootspec-secureboot";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {self, ...} @ inputs: let
    inherit (self) outputs;
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      imports = [
        inputs.flake-parts.flakeModules.easyOverlay

        ./modules
        ./packages
      ];

      flake = {
        darwinConfigurations = {};

        nixosConfigurations = {
          desktop = inputs.nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit outputs;

              # Catppuccin flavour
              # https://github.com/catppuccin/catppuccin#-palette
              flavour = "mocha";
            };

            modules = [
              # Enable our overlays to replace built-in packages
              {nixpkgs.overlays = builtins.attrValues outputs.overlays;}

              inputs.nixos-hardware.nixosModules.common-cpu-amd
              inputs.nixos-hardware.nixosModules.common-gpu-amd

              self.nixosModules.agenix
              self.nixosModules.bootspec-secureboot
              self.nixosModules.home-manager

              self.nixosModules.amd-ryzen
              self.nixosModules.catppuccin
              self.nixosModules.desktop
              self.nixosModules.gnome
              self.nixosModules.persistence
              self.nixosModules.podman
              self.nixosModules.system
              self.nixosModules.virtualisation

              {
                age.secrets = {
                  passwordfile-matthew.file = secrets/passwordfile-matthew.age;
                };

                age.identityPaths = ["/persist/etc/ssh/ssh_host_ed25519_key"];
              }

              ./systems/desktop
              ./users
            ];
          };

          iso = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel.nix"
            ];
          };
        };
      };

      perSystem = {
        pkgs,
        system,
        ...
      }: {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            inputs.agenix.packages."${system}".default

            pkgs.gitsign
          ];
        };
      };
    };
}
