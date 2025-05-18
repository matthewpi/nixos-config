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
      inputs = {
        astal.follows = "astal";
        nixpkgs.follows = "nixpkgs";
      };
    };

    astal = {
      url = "github:Aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
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

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
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
        hyprland-protocols.follows = "hyprland-protocols";
        hyprlang.follows = "hyprlang";
        hyprutils.follows = "hyprutils";
        hyprwayland-scanner.follows = "hyprwayland-scanner";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems-linux";
      };
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs = {
        aquamarine.follows = "aquamarine";
        hyprcursor.follows = "hyprcursor";
        hyprgraphics.follows = "hyprgraphics";
        hyprland-protocols.follows = "hyprland-protocols";
        hyprland-qtutils.follows = "hyprland-qtutils";
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

    hyprland-qt-support = {
      url = "github:hyprwm/hyprland-qt-support";
      inputs = {
        hyprlang.follows = "hyprlang";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems-linux";
      };
    };

    hyprland-qtutils = {
      url = "github:hyprwm/hyprland-qtutils";
      inputs = {
        hyprland-qt-support.follows = "hyprland-qt-support";
        hyprlang.follows = "hyprlang";
        hyprutils.follows = "hyprutils";
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
        hyprwayland-scanner.follows = "hyprwayland-scanner";
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
        hyprland-qt-support.follows = "hyprland-qt-support";
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
      url = "github:matthewpi/lanzaboote/fixes";
      inputs = {
        flake-compat.follows = "flake-compat";
        flake-parts.follows = "flake-parts";
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
        hyprutils.follows = "hyprutils";
        hyprwayland-scanner.follows = "hyprwayland-scanner";
      };
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };

    nix = {
      url = "github:DeterminateSystems/nix-src/v3.5.2";
      inputs = {
        flake-parts.follows = "flake-parts";
        git-hooks-nix.follows = "";
        nixpkgs.follows = "nixpkgs";
        nixpkgs-23-11.follows = "";
        nixpkgs-regression.follows = "";
      };
    };

    # NOTE: unfree
    determinate-nixd-x86_64-linux = {
      url = "https://install.determinate.systems/determinate-nixd/tag/v3.5.2/x86_64-linux";
      flake = false;
    };
  };

  outputs = {self, ...} @ inputs: let
    inherit (self) outputs;

    mkNixpkgs = system:
      import inputs.nixpkgs {
        localSystem = {inherit system;};

        # Add our overlays.
        overlays = builtins.attrValues outputs.overlays;

        config = {
          # Allow some unfree packages by name.
          allowUnfreePredicate = pkg:
            builtins.elem (inputs.nixpkgs.lib.getName pkg) [
              "1password"
              "1password-cli"
              "cider2"
              "intelephense"
              "obsidian"
              "slack"
              "star-citizen"
              "steam"
              "steam-unwrapped"

              # Firefox Extensions (nxb)
              "night-eye-dark-mode"
              "onepassword-password-manager"
            ];

          # NOTE: only enable if ollama is being used.
          # rocmSupport = true;
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
          # Configuration revision to this flake's Git revision.
          #
          # NOTE: `src.rev` is only available if the tree of this repository
          # is clean (no uncommitted changes).
          configurationRevision = inputs.nixpkgs.lib.mkIf (self ? rev) self.rev;
        in {
          lib = {inherit mkNixpkgs;};

          nixosConfigurations.nxd = inputs.nixpkgs.lib.nixosSystem {
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

                system = {inherit configurationRevision;};
              })

              inputs.nixos-hardware.nixosModules.common-cpu-amd
              inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
              inputs.nixos-hardware.nixosModules.common-gpu-amd

              inputs.agenix.nixosModules.default
              inputs.disko.nixosModules.disko
              inputs.home-manager.nixosModules.home-manager

              self.nixosModules.desktop
              self.nixosModules.determinate
              self.nixosModules.hyprland
              self.nixosModules.persistence
              self.nixosModules.podman
              self.nixosModules.secureboot
              self.nixosModules.system
              self.nixosModules.tailscale
              # self.nixosModules.virtualisation

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

              ./builders
              ./systems/nxd
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

                system = {inherit configurationRevision;};
              })

              inputs.nixos-hardware.nixosModules.framework-16-7040-amd

              inputs.agenix.nixosModules.default
              inputs.disko.nixosModules.disko
              inputs.home-manager.nixosModules.home-manager

              self.nixosModules.desktop
              self.nixosModules.determinate
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

              ./builders
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
                []
                ++ lib.optionals (system == "x86_64-linux") [
                  inputs.agenix.packages."${system}".default
                ];
            };
          };

          treefmt = {
            projectRootFile = "flake.nix";

            programs = {
              # Enable actionlint, a GitHub Actions static checker.
              actionlint.enable = true;

              # Enable alejandra, a Nix formatter.
              alejandra.enable = true;

              # Enable deadnix, a Nix linter/formatter that removes un-used Nix code.
              deadnix.enable = true;

              # Enable prettier, a... TODO
              prettier = {
                enable = true;
                includes = [
                  "*.css"
                  "*.js"
                  "*.json"
                  "*.ts"
                  "*.tsx"
                  "*.md"
                  "*.scss"
                  "*.yaml"
                ];
              };

              # Enable shellcheck, a shell script linter.
              shellcheck.enable = true;

              # Enable shfmt, a shell script formatter.
              shfmt = {
                enable = true;
                indent_size = 0; # 0 causes shfmt to use tabs
              };

              # Enable yamlfmt, a YAML formatter.
              yamlfmt = {
                enable = true;
                settings.formatter = {
                  type = "basic";
                  retain_line_breaks_single = true;
                };
              };
            };

            # Ensure no files within `node_modules` get formatted.
            settings.global.excludes = [
              "**/node_modules"
              "secrets/*.age"
            ];
          };
        };
      }
    );
}
