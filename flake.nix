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
      url = "github:hyprwm/Hyprland/v0.53.1";
      inputs = {
        aquamarine.follows = "aquamarine";
        hyprcursor.follows = "hyprcursor";
        hyprgraphics.follows = "hyprgraphics";
        hyprland-guiutils.follows = "hyprland-guiutils";
        hyprland-protocols.follows = "hyprland-protocols";
        hyprlang.follows = "hyprlang";
        hyprutils.follows = "hyprutils";
        hyprwayland-scanner.follows = "hyprwayland-scanner";
        hyprwire.follows = "hyprwire";
        xdph.follows = "xdph";
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks.follows = "";
        systems.follows = "systems-linux";
      };
    };

    hyprland-guiutils = {
      url = "github:hyprwm/hyprland-guiutils";
      inputs = {
        aquamarine.follows = "aquamarine";
        hyprgraphics.follows = "hyprgraphics";
        hyprlang.follows = "hyprlang";
        hyprtoolkit.follows = "hyprtoolkit";
        hyprutils.follows = "hyprutils";
        hyprwayland-scanner.follows = "hyprwayland-scanner";
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

    hyprland-qt-support = {
      url = "github:hyprwm/hyprland-qt-support";
      inputs = {
        hyprlang.follows = "hyprlang";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems-linux";
      };
    };

    hyprtoolkit = {
      url = "github:hyprwm/hyprtoolkit";
      inputs = {
        aquamarine.follows = "aquamarine";
        hyprgraphics.follows = "hyprgraphics";
        hyprlang.follows = "hyprlang";
        hyprutils.follows = "hyprutils";
        hyprwayland-scanner.follows = "hyprwayland-scanner";
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
        aquamarine.follows = "aquamarine";
        hyprlang.follows = "hyprlang";
        hyprgraphics.follows = "hyprgraphics";
        hyprtoolkit.follows = "hyprtoolkit";
        hyprutils.follows = "hyprutils";
        hyprwayland-scanner.follows = "hyprwayland-scanner";
        hyprwire.follows = "hyprwire";
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

    hyprwire = {
      url = "github:hyprwm/hyprwire";
      inputs = {
        hyprutils.follows = "hyprutils";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems-linux";
      };
    };

    impermanence = {
      url = "github:nix-community/impermanence";
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
    };

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
        hyprland-protocols.follows = "hyprland-protocols";
        hyprlang.follows = "hyprlang";
        hyprutils.follows = "hyprutils";
        hyprwayland-scanner.follows = "hyprwayland-scanner";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems-linux";
      };
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} ({self, ...}: {
      systems = ["x86_64-linux"];

      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
        inputs.treefmt-nix.flakeModule

        ./modules
        ./packages
      ];

      flake = {
        lib.mkNixpkgs = system:
          import inputs.nixpkgs {
            localSystem = {inherit system;};

            # Add our overlays.
            overlays = builtins.attrValues self.overlays;

            config = {
              # Allow some unfree packages by name.
              allowUnfreePredicate = pkg: let
                name = inputs.nixpkgs.lib.getName pkg;
              in (
                if inputs.nixpkgs.lib.hasPrefix "cuda_" name
                then true
                else
                  builtins.elem name [
                    "1password"
                    "1password-cli"
                    "discord"
                    "intelephense"
                    "obsidian"
                    "slack"
                    "star-citizen"
                    "steam"
                    "steam-unwrapped"

                    # Firefox Extensions (nxb)
                    "night-eye-dark-mode"
                    "onepassword-password-manager"

                    # NVIDIA (desktop)
                    "cuda-merged"
                    "libcufft"
                    "libcublas"
                    "libcurand"
                    "libcusolver"
                    "libnvjitlink"
                    "libcusparse"
                    "libnpp"

                    "nvidia-x11"
                    "nvidia-settings"
                  ]
              );
            };
          };

        nixosConfigurations.matthew-desktop = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [./systems/desktop];

          specialArgs = {
            inherit inputs;
            configurationRevision =
              if (self ? rev)
              then self.rev
              else null;
            outputs = self;
            isDesktop = true;
          };
        };

        nixosConfigurations.nxb = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [./systems/nxb];

          specialArgs = {
            inherit inputs;
            configurationRevision =
              if (self ? rev)
              then self.rev
              else null;
            outputs = self;
            isDesktop = false;
          };
        };
      };

      perSystem = {
        pkgs,
        self',
        system,
        ...
      }: {
        _module.args.pkgs = self.lib.mkNixpkgs system;

        packages = {
          agenix = inputs.agenix.packages."${system}".default;
          ags = with inputs.ags.packages."${system}";
            ags.override {
              extraPackages = [
                apps
                battery
                bluetooth
                hyprland
                mpris
                notifd
                powerprofiles
                tray
                wireplumber
                pkgs.libadwaita
              ];
            };
        };

        devShells.default = pkgs.mkShellNoCC {
          packages = [
            self'.packages.agenix
            self'.packages.ags
          ];
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
    });
}
