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
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
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
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems-linux";
      };
    };

    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs = {
        hyprcursor.follows = "hyprcursor";
        hyprlang.follows = "hyprlang";
        hyprutils.follows = "hyprutils";
        xdph.follows = "xdph";
        nixpkgs.follows = "nixpkgs";
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
        hyprutils.follows = "hyprutils";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems-linux";
      };
    };

    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      inputs = {
        hyprlang.follows = "hyprlang";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems-linux";
      };
    };

    hyprpicker = {
      url = "github:hyprwm/hyprpicker";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprutils = {
      url = "github:hyprwm/hyprutils";
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

    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    systems.url = "github:nix-systems/default";
    systems-linux.url = "github:nix-systems/default-linux";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xdph = {
      url = "github:hyprwm/xdg-desktop-portal-hyprland";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems-linux";
        hyprland-protocols.follows = "hyprland-protocols";
        hyprlang.follows = "hyprlang";
      };
    };
  };

  #nixConfig = {
  #  extra-substituters = [
  #    "https://cache.nicetry.lol"
  #  ];
  #  extra-trusted-public-keys = [
  #    "cache.nicetry.lol-1:JnmGgdqevlSBH1ZpAemFGR+AChxgGcNKW9G3ThtW4bk="
  #  ];
  #};

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
          #hydraJobs = let
          #  inherit (inputs.nixpkgs.lib) mapAttrs;
          #  getCfg = _: cfg: cfg.config.system.build.toplevel;
          #in {
          #  hosts = mapAttrs getCfg self.nixosConfigurations;
          #
          #  checks = {
          #    inherit (self.checks) x86_64-linux;
          #  };
          #
          #  packages = {
          #    inherit (self.packages) x86_64-linux;
          #  };
          #};

          nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
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

              # Right now, the `amd-ryzen` module enables zenpower which doesn't
              # support Zen 4. I just upgraded from Zen 3 to Zen 4, hence why this
              # is now disabled.
              # self.nixosModules.amd-ryzen
              self.nixosModules.catppuccin
              self.nixosModules.desktop
              self.nixosModules.hyprland
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

                  desktop-resolved = {
                    file = secrets/desktop-resolved.age;
                    path = "/etc/systemd/resolved.conf";
                    mode = "444";
                    owner = "root";
                    group = "root";
                  };
                };

                age.identityPaths = ["/persist/etc/ssh/ssh_host_ed25519_key"];
              }

              ./systems/desktop
              ./users
            ];
          };

          darwinConfigurations."Matthews-MBP" = inputs.darwin.lib.darwinSystem {
            specialArgs = {
              inherit inputs outputs;

              flavour = "mocha";
            };

            modules = [
              nixFlakeSettings
              inputs.home-manager.darwinModules.home-manager
              ./systems/mbp
            ];
          };
        };

        perSystem = {
          lib,
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
              "**/pnpm-lock.yaml"
            ];
          };
        };
      }
    );
}
