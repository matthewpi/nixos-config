{
  config,
  isDesktop,
  lib,
  ...
}: let
  hmConfig = config.home-manager.users.matthew;
in {
  # Impermanence
  environment.persistence."/persist".users.matthew.directories =
    []
    ++ lib.optional hmConfig.programs.atuin.enable {
      directory = ".local/share/atuin";
      mode = "0700";
    }
    ++ lib.optional hmConfig.programs.bat.enable {
      directory = ".cache/bat";
      mode = "0700";
    }
    ++ lib.optionals hmConfig.programs.direnv.enable [
      {
        directory = ".cache/direnv";
        mode = "0700";
      }
      {
        directory = ".local/share/direnv";
        mode = "0700";
      }
    ]
    ++ lib.optional hmConfig.programs.gh.enable {
      directory = ".config/gh";
      mode = "0700";
    }
    ++ lib.optionals hmConfig.programs.firefox.enable [
      {
        directory = ".cache/mozilla";
        mode = "0700";
      }
      {
        directory = ".mozilla/firefox";
        mode = "0700";
      }
    ]
    ++ lib.optionals hmConfig.programs.neovim.enable [
      {
        directory = ".cache/nvim";
        mode = "0700";
      }
      {
        directory = ".local/state/nvim";
        mode = "0700";
      }
    ]
    ++ lib.optional hmConfig.programs.ssh.enable {
      directory = ".cache/ssh";
      mode = "0700";
    }
    ++ lib.optional hmConfig.programs.starship.enable {
      directory = ".cache/starship";
      mode = "0700";
    }
    ++ lib.optional hmConfig.programs.vscode.enable {
      directory = ".config/VSCodium";
      mode = "0700";
    }
    ++ lib.optional hmConfig.programs.zed-editor.enable {
      directory = ".local/share/zed";
      mode = "0700";
    }
    ++ lib.optional hmConfig.programs.zsh.enable {
      directory = ".local/share/zsh";
      mode = "0700";
    }
    ++ lib.optional hmConfig.services.gnome-keyring.enable {
      directory = ".local/share/keyrings";
      mode = "0700";
    }
    ++ lib.optional config.programs.steam.enable {
      directory = ".local/share/Steam";
      mode = "0700";
    }
    ++ lib.optionals isDesktop [
      {
        directory = ".config/streamdeck";
        mode = "0700";
      }
      {
        directory = "Games";
        mode = "0700";
      }
    ]
    ++ [
      {
        directory = ".cache/ags";
        mode = "0700";
      }
      {
        directory = ".cache/amberol";
        mode = "0700";
      }
      {
        directory = ".cache/buf";
        mode = "0700";
      }
      {
        directory = ".cache/chromium";
        mode = "0700";
      }
      {
        directory = ".cache/containers";
        mode = "0700";
      }
      {
        directory = ".cache/dconf";
        mode = "0700";
      }
      {
        directory = ".cache/evolution";
        mode = "0700";
      }
      {
        directory = ".cache/fontconfig";
        mode = "0700";
      }
      {
        directory = ".cache/gauntlet";
        mode = "0700";
      }
      {
        directory = ".cache/golangci-lint";
        mode = "0700";
      }
      {
        directory = ".cache/go-build";
        mode = "0700";
      }
      {
        directory = ".cache/gstreamer-1.0";
        mode = "0700";
      }
      {
        directory = ".cache/hoppscotch";
        mode = "0700";
      }
      {
        directory = ".cache/mesa_shader_cache";
        mode = "0700";
      }
      {
        directory = ".cache/nix";
        mode = "0700";
      }
      {
        directory = ".cache/nixpkgs-review";
        mode = "0700";
      }
      {
        directory = ".cache/npm";
        mode = "0700";
      }
      {
        directory = ".cache/pnpm";
        mode = "0700";
      }
      {
        directory = ".cache/tracker3";
        mode = "0700";
      }
      {
        directory = ".cache/tree-sitter";
        mode = "0700";
      }
      {
        directory = ".cache/turbo";
        mode = "0700";
      }

      {
        directory = ".config/1Password";
        mode = "0700";
      }
      {
        directory = ".config/Flipper Devices Inc";
        mode = "0700";
      }
      {
        directory = ".config/Ledger Live";
        mode = "0700";
      }
      {
        directory = ".config/OpenLens";
        mode = "0700";
      }
      {
        directory = ".config/Proton Mail";
        mode = "0700";
      }
      {
        directory = ".config/Signal";
        mode = "0700";
      }
      {
        directory = ".config/Slack";
        mode = "0700";
      }
      # {
      #   directory = ".config/Termius";
      #   mode = "0700";
      # }
      {
        directory = ".config/attic";
        mode = "0700";
      }
      {
        directory = ".config/aws";
        mode = "0700";
      }
      {
        directory = ".config/chromium";
        mode = "0700";
      }
      {
        directory = ".config/easyeffects";
        mode = "0700";
      }
      {
        directory = ".config/evolution";
        mode = "0700";
      }
      {
        directory = ".config/discord";
        mode = "0700";
      }
      {
        directory = ".config/gauntlet";
        mode = "0700";
      }
      {
        directory = ".config/go";
        mode = "0700";
      }
      {
        directory = ".config/java";
        mode = "0700";
      }
      {
        directory = ".config/kubernetes";
        mode = "0700";
      }
      {
        directory = ".config/libreoffice";
        mode = "0700";
      }
      {
        directory = ".config/nautilus";
        mode = "0700";
      }
      {
        directory = ".config/nix";
        mode = "0700";
      }
      {
        directory = ".config/obsidian";
        mode = "0700";
      }
      {
        directory = ".config/op";
        mode = "0700";
      }
      {
        directory = ".config/rclone";
        mode = "0700";
      }
      {
        directory = ".config/sh.cider.electron";
        mode = "0700";
      }
      {
        directory = ".config/sh.cider.genten";
        mode = "0700";
      }
      {
        directory = ".config/turborepo";
        mode = "0700";
      }
      {
        directory = ".config/vesktop";
        mode = "0700";
      }
      {
        directory = ".config/zed";
        mode = "0700";
      }

      # I hate this, JetBrains uses it to store
      # auth data and agreement to their ToS
      # TODO: remove once we have verified our _JAVA_OPTIONS override works
      {
        directory = ".java";
        mode = "0700";
      }

      # Kubernetes
      {
        directory = ".kube";
        mode = "0700";
      }
      {
        # ref; https://github.com/lensapp/lens/issues/2494
        directory = ".k8slens";
        mode = "0700";
      }

      {
        directory = ".local/share/PrismLauncher";
        mode = "0700";
      }
      {
        directory = ".local/share/bottles";
        mode = "0700";
      }
      {
        directory = ".local/share/cargo";
        mode = "0700";
      }
      {
        directory = ".local/share/containers";
        mode = "0700";
      }
      {
        directory = ".local/share/evolution";
        mode = "0700";
      }
      {
        directory = ".local/share/gauntlet";
        mode = "0700";
      }
      {
        directory = ".local/share/gnome-settings-daemon";
        mode = "0700";
      }
      {
        directory = ".local/share/gnome-shell";
        mode = "0700";
      }
      {
        directory = ".local/share/go";
        mode = "0700";
      }
      {
        directory = ".local/share/gnupg";
        mode = "0700";
      }
      {
        directory = ".local/share/gvfs-metadata";
        mode = "0700";
      }
      {
        directory = ".local/share/hoppscotch";
        mode = "0700";
      }
      {
        directory = ".local/share/io.hoppscotch.desktop";
        mode = "0700";
      }
      {
        directory = ".local/share/icc";
        mode = "0700";
      }
      {
        directory = ".local/share/nautilus";
        mode = "0700";
      }
      {
        directory = ".local/share/npm";
        mode = "0700";
      }
      {
        directory = ".local/share/obsidian";
        mode = "0700";
      }
      {
        directory = ".local/share/pnpm";
        mode = "0700";
      }
      {
        directory = ".local/share/sounds";
        mode = "0700";
      }
      {
        directory = ".local/share/step";
        mode = "0700";
      }
      {
        directory = ".local/share/turborepo";
        mode = "0700";
      }
      {
        directory = ".local/share/vulkan";
        mode = "0700";
      }

      {
        directory = ".local/state/gauntlet";
        mode = "0700";
      }
      {
        directory = ".local/state/home-manager";
        mode = "0700";
      }
      {
        directory = ".local/state/nix";
        mode = "0700";
      }
      {
        directory = ".local/state/wireplumber";
        mode = "0700";
      }

      # # TODO: patch zen to allow using a different directory
      # {
      #   directory = ".zen";
      #   mode = "0700";
      # }

      "Documents"
      "Downloads"
      "Music"
      "Pictures"
      "Videos"
    ];
}
