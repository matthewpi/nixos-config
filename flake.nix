{
  description = "Matthew's NixOS Configurations";

  inputs = {
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        darwin.follows = "darwin";
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };

    ags = {
      url = "github:Aylur/ags/v1";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems-linux";
      };
    };

    aquamarine = {
      url = "github:hyprwm/aquamarine";
      inputs = {
        hyprutils.follows = "hyprutils";
        hyprwayland-scanner.follows = "hyprwayland-scanner";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems-linux";
      };
    };

    catppuccin.url = "github:catppuccin/nix";

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    flake-registry = {
      url = "github:nixos/flake-registry";
      flake = false;
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprcursor = {
      url = "github:hyprwm/hyprcursor";
      inputs = {
        hyprlang.follows = "hyprlang";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems-linux";
      };
    };

    hypridle = {
      url = "github:hyprwm/hypridle";
      inputs = {
        hyprlang.follows = "hyprlang";
        hyprutils.follows = "hyprutils";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems-linux";
      };
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs = {
        aquamarine.follows = "aquamarine";
        hyprcursor.follows = "hyprcursor";
        hyprland-protocols.follows = "hyprland-protocols";
        hyprlang.follows = "hyprlang";
        hyprutils.follows = "hyprutils";
        hyprwayland-scanner.follows = "hyprwayland-scanner";
        xdph.follows = "xdph";
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks.follows = "";
        systems.follows = "systems-linux";
      };
    };

    hyprland-protocols = {
      url = "github:hyprwm/hyprland-protocols";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems-linux";
      };
    };

    hyprlang = {
      url = "github:hyprwm/hyprlang";
      inputs = {
        hyprutils.follows = "hyprutils";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems-linux";
      };
    };

    hyprlock = {
      url = "github:hyprwm/hyprlock";
      inputs = {
        hyprlang.follows = "hyprlang";
        hyprgraphics.follows = "hyprgraphics";
        hyprutils.follows = "hyprutils";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems-linux";
      };
    };

    hyprgraphics = {
      url = "github:hyprwm/hyprgraphics";
      inputs = {
        hyprutils.follows = "hyprutils";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems-linux";
      };
    };

    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      inputs = {
        hyprlang.follows = "hyprlang";
        hyprgraphics.follows = "hyprgraphics";
        hyprutils.follows = "hyprutils";
        hyprwayland-scanner.follows = "hyprwayland-scanner";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems-linux";
      };
    };

    hyprpolkitagent = {
      url = "github:hyprwm/hyprpolkitagent";
      inputs = {
        hyprutils.follows = "hyprutils";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems-linux";
      };
    };

    hyprutils = {
      url = "github:hyprwm/hyprutils";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems-linux";
      };
    };

    hyprwayland-scanner = {
      url = "github:hyprwm/hyprwayland-scanner";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems-linux";
      };
    };

    impermanence.url = "github:nix-community/impermanence";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs = {
        flake-compat.follows = "flake-compat";
        flake-parts.follows = "flake-parts";
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks-nix.follows = "";
      };
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming = {
      url = "github:matthewpi/nix-gaming/updates";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nur.url = "github:nix-community/NUR";

    systems.url = "github:nix-systems/default";
    systems-linux.url = "github:nix-systems/default-linux";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xdph = {
      url = "github:hyprwm/xdg-desktop-portal-hyprland/ff6b2a51e95ca4ac590801e626c5ef777283a0fe";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems-linux";
        hyprland-protocols.follows = "hyprland-protocols";
        hyprlang.follows = "hyprlang";
        hyprutils.follows = "hyprutils";
        hyprwayland-scanner.follows = "hyprwayland-scanner";
      };
    };
  };

  outputs = {self, ...} @ inputs: let
    inherit (self) outputs;

    mkNixpkgs = system:
      import inputs.nixpkgs {
        localSystem = {inherit system;};

        # Add our overlays.
        overlays = builtins.attrValues outputs.overlays;

        # Allow unfree packages
        config = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
        };
      };
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} (
      {self, ...}: {
        systems = ["x86_64-linux"];

        imports = [
          inputs.flake-parts.flakeModules.easyOverlay
          inputs.treefmt-nix.flakeModule

          ./modules
          ./packages
        ];

        flake = let
          nixFlakeSettings = {
            # Set nixpkgs to the one used by the flake. (affects legacy commands and comma)
            nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

            # Add nixpkgs to the registry. (affects flake commands)
            nix.registry.nixpkgs.flake = inputs.nixpkgs;

            # Pre-fetch the flake-registry to prevent it from being re-downloaded.
            nix.settings.flake-registry = "${inputs.flake-registry}/flake-registry.json";
          };
        in {
          lib = {inherit mkNixpkgs;};

          nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";

            specialArgs = {
              inherit inputs outputs;
              isDesktop = true;
            };

            modules = [
              ({
                lib,
                outputs,
                ...
              }: {
                nixpkgs = {
                  config = lib.mkForce {};
                  pkgs = outputs.lib.mkNixpkgs "x86_64-linux";
                  hostPlatform = "x86_64-linux";
                };
              })
              nixFlakeSettings

              inputs.nixos-hardware.nixosModules.common-cpu-amd
              inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
              inputs.nixos-hardware.nixosModules.common-gpu-amd

              inputs.agenix.nixosModules.default
              inputs.disko.nixosModules.disko
              inputs.home-manager.nixosModules.home-manager

              inputs.nix-gaming.nixosModules.platformOptimizations
              {
                programs.steam.platformOptimizations.enable = true;
              }

              self.nixosModules.desktop
              self.nixosModules.hyprland
              self.nixosModules.persistence
              self.nixosModules.podman
              self.nixosModules.secureboot
              self.nixosModules.system
              self.nixosModules.tailscale
              self.nixosModules.virtualisation

              {
                age.identityPaths = ["/persist/etc/ssh/ssh_host_ed25519_key"];
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

                  desktop-resolved = {
                    file = secrets/desktop-resolved.age;
                    path = "/etc/systemd/resolved.conf";
                    mode = "444";
                    owner = "root";
                    group = "root";
                  };
                };
              }

              # ./builders
              ./systems/desktop
              ./users
            ];
          };

          nixosConfigurations.nxb = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";

            specialArgs = {
              inherit inputs outputs;
              isDesktop = false;
            };

            modules = [
              ({
                lib,
                outputs,
                ...
              }: {
                nixpkgs = {
                  config = lib.mkForce {};
                  pkgs = outputs.lib.mkNixpkgs "x86_64-linux";
                  hostPlatform = "x86_64-linux";
                };
              })
              nixFlakeSettings

              inputs.nixos-hardware.nixosModules.framework-16-7040-amd

              inputs.agenix.nixosModules.default
              inputs.disko.nixosModules.disko
              inputs.home-manager.nixosModules.home-manager

              self.nixosModules.desktop
              self.nixosModules.hyprland
              self.nixosModules.persistence
              self.nixosModules.podman
              self.nixosModules.secureboot
              self.nixosModules.system
              self.nixosModules.tailscale

              {
                age.identityPaths = ["/persist/etc/ssh/ssh_host_ed25519_key"];
                age.secrets = {
                  passwordfile-matthew.file = secrets/passwordfile-matthew.age;
                  desktop-resolved = {
                    file = secrets/desktop-resolved.age;
                    path = "/etc/systemd/resolved.conf";
                    mode = "444";
                    owner = "root";
                    group = "root";
                  };
                };
              }

              ./systems/nxb
              ./users
            ];
          };
        };

        perSystem = {
          lib,
          pkgs,
          system,
          ...
        }: {
          _module.args.pkgs = mkNixpkgs system;

          devShells = {
            ci = pkgs.mkShellNoCC {buildInputs = [pkgs.gitsign];};

            default = pkgs.mkShellNoCC {
              buildInputs =
                (with pkgs; [
                  gitsign
                  nodejs_20
                  nodePackages.pnpm
                ])
                ++ lib.optional (system == "x86_64-linux") inputs.agenix.packages."${system}".default;
            };
          };

          treefmt = {
            projectRootFile = "flake.nix";

            programs = {
              alejandra.enable = true;
              deadnix.enable = true;
              prettier = {
                enable = true;
                includes = [
                  "*.css"
                  "*.js"
                  "*.ts"
                  "*.md"
                  "*.scss"
                  "*.yaml"
                ];
              };
              shellcheck.enable = true;
              shfmt = {
                enable = true;
                # https://flake.parts/options/treefmt-nix.html#opt-perSystem.treefmt.programs.shfmt.indent_size
                # 0 causes shfmt to use tabs
                indent_size = 0;
              };
            };

            settings.global.excludes = [
              "**/node_modules"
              "pnpm-lock.yaml"
            ];
          };
        };
      }
    );
}
