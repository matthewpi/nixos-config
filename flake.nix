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

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    flake-registry = {
      url = "github:nixos/flake-registry";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {self, ...} @ inputs: let
    inherit (self) outputs;
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} (
      {self, ...}: {
        systems = ["x86_64-darwin" "x86_64-linux"];

        imports = [
          inputs.flake-parts.flakeModules.easyOverlay
          inputs.treefmt-nix.flakeModule

          ./modules
          ./packages
        ];

        flake = let
          nixFlakeSettings = {
            # Enable our overlays to replace built-in packages
            nixpkgs.overlays = builtins.attrValues outputs.overlays;

            # Set nixpkgs to the one used by the flake. (affects legacy commands and comma)
            nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

            # Add nixpkgs to the registry. (affects flake commands)
            nix.registry.nixpkgs.flake = inputs.nixpkgs;

            # Pre-fetch the flake-registry to prevent it from being re-downloaded.
            nix.settings.flake-registry = "${inputs.flake-registry}/flake-registry.json";
          };
        in rec {
          hydraJobs = let
            inherit (inputs.nixpkgs.lib) mapAttrs;
            getCfg = _: cfg: cfg.config.system.build.toplevel;
          in {
            hosts = mapAttrs getCfg self.nixosConfigurations;

            checks = {
              inherit (self.checks) x86_64-linux;
            };

            packages = {
              inherit (self.packages) x86_64-linux;
            };
          };

          nixosConfigurations = {
            desktop = inputs.nixpkgs.lib.nixosSystem {
              specialArgs = {
                inherit inputs outputs;

                # Catppuccin flavour
                # https://github.com/catppuccin/catppuccin#-palette
                flavour = "mocha";
              };

              modules = [
                nixFlakeSettings

                inputs.nixos-hardware.nixosModules.common-cpu-amd
                inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
                inputs.nixos-hardware.nixosModules.common-gpu-amd

                inputs.agenix.nixosModules.default
                inputs.home-manager.nixosModules.home-manager

                self.nixosModules.amd-ryzen
                self.nixosModules.catppuccin
                self.nixosModules.desktop
                self.nixosModules.gnome
                self.nixosModules.persistence
                self.nixosModules.podman
                self.nixosModules.secureboot
                self.nixosModules.system
                # self.nixosModules.virtualisation

                {
                  age.secrets = {
                    passwordfile-matthew.file = secrets/passwordfile-matthew.age;

                    restic-matthew-code.file = secrets/restic-matthew-code.age;
                    restic-matthew-code-repository = {
                      file = secrets/restic-matthew-code-repository.age;
                      mode = "400";
                      owner = "matthew";
                      group = "users";
                    };
                    restic-matthew-code-password = {
                      file = secrets/restic-matthew-code-password.age;
                      mode = "400";
                      owner = "matthew";
                      group = "users";
                    };
                  };

                  age.identityPaths = ["/persist/etc/ssh/ssh_host_ed25519_key"];
                }

                ./systems/desktop
                ./users
              ];
            };
          };
        };

        perSystem = {
          pkgs,
          system,
          ...
        }: {
          # Initialize pkgs with our overlays
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = builtins.attrValues outputs.overlays;
            config.allowUnfree = true;
          };

          devShells = {
            ci = pkgs.mkShellNoCC {buildInputs = [pkgs.gitsign];};

            default = pkgs.mkShellNoCC {
              buildInputs = [
                inputs.agenix.packages."${system}".default
                pkgs.gitsign
              ];
            };
          };

          treefmt = {
            projectRootFile = "flake.nix";

            programs = {
              alejandra.enable = true;
              deadnix.enable = true;
              shellcheck.enable = true;
              shfmt = {
                enable = true;
                # https://flake.parts/options/treefmt-nix.html#opt-perSystem.treefmt.programs.shfmt.indent_size
                # 0 causes shfmt to use tabs
                indent_size = 0;
              };
            };
          };
        };
      }
    );
}
