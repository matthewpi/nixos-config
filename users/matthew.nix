{
  config,
  lib,
  pkgs,
  ...
}: {
  # Configure matthew with home-manager.
  home-manager.users = {
    matthew = import ./matthew/linux.nix;
  };

  # Enable steam hardware
  hardware.steam-hardware.enable = true;

  # Enable zsh
  programs.zsh = {
    enable = true;
    vteIntegration = true;
  };

  # Allow matthew access to 1Password
  programs._1password-gui.polkitPolicyOwners = ["matthew"];

  # Enable yubikey-agent
  services.yubikey-agent.enable = true;
  systemd.user.services."yubikey-agent".serviceConfig.Slice = "background.slice";
  programs.gnupg.agent.pinentryFlavor = "gnome3";

  # Enable gamescope
  programs.gamescope = {
    enable = true;
    capSysNice = true;
    args = ["--adaptive-sync" "--force-composition" "--nested-width 1920" "--nested-height 1080" "--nested-refresh 144" "--fullscreen" "--rt" "--expose-wayland" "--force-grab-cursor"];
  };

  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraEnv = {
        # Manually set SDL_VIDEODRIVER to x11.
        #
        # This fixes the `gldriverquery` segfault and issues with EAC crashing on games like Rust,
        # rather than gracefully disabling itself.
        SDL_VIDEODRIVER = "x11";
        #OBS_VKCAPTURE = true;
      };

      extraPkgs = pkgs:
        with pkgs; [
          xorg.libXcursor
          xorg.libXi
          xorg.libXinerama
          xorg.libXScrnSaver
          libpng
          libpulseaudio
          libvorbis
          stdenv.cc.cc.lib
          libkrb5
          keyutils
        ];
    };
    gamescopeSession = {
      enable = true;
    };
    #localNetworkGameTransfers.openFirewall = true;
  };

  # Enable the wireshark dumpcap security wrapper.
  # This allows us to call dumpcap without using separate privilege escalation.
  programs.wireshark.enable = true;

  # Configure the matthew user.
  users.users.matthew = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups =
      ["wheel"]
      ++ lib.optionals config.programs.corectrl.enable ["corectrl"]
      ++ lib.optionals config.virtualisation.libvirtd.enable ["libvirtd" "qemu-libvirtd"]
      ++ lib.optionals config.programs.wireshark.enable ["wireshark"];
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAJ30VI7vAdrs2MDgkNHSQMJt2xBtBLrirVhinSyteeU"];
    hashedPasswordFile = config.age.secrets.passwordfile-matthew.path;
  };

  # Impermanence
  environment.persistence."/persist".users = {
    matthew = {
      directories = [
        {
          directory = ".cache/JetBrains";
          mode = "0700";
        }
        {
          directory = ".cache/ags";
          mode = "0700";
        }
        {
          directory = ".cache/amberol";
          mode = "0700";
        }
        {
          directory = ".cache/bat";
          mode = "0700";
        }
        {
          directory = ".cache/buf";
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
          directory = ".cache/gnome-software";
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
          directory = ".cache/mesa_shader_cache";
          mode = "0700";
        }
        {
          directory = ".cache/mozilla";
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
          directory = ".cache/nvim";
          mode = "0700";
        }
        {
          directory = ".cache/pnpm";
          mode = "0700";
        }
        {
          directory = ".cache/spotify";
          mode = "0700";
        }
        {
          directory = ".cache/ssh";
          mode = "0700";
        }
        {
          directory = ".cache/starship";
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
          directory = ".config/Cider";
          mode = "0700";
        }
        {
          directory = ".config/Element";
          mode = "0700";
        }
        {
          directory = ".config/JetBrains";
          mode = "0700";
        }
        {
          directory = ".config/Ledger Live";
          mode = "0700";
        }
        {
          directory = ".config/WebCord";
          mode = "0700";
        }
        {
          directory = ".config/OpenLens";
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
        {
          directory = ".config/Termius";
          mode = "0700";
        }
        {
          directory = ".config/VSCodium";
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
          directory = ".config/discordcanary";
          mode = "0700";
        }
        {
          directory = ".config/discordptb";
          mode = "0700";
        }
        {
          directory = ".config/gh";
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
          directory = ".config/lunarclient";
          mode = "0700";
        }
        {
          directory = ".config/nautilus";
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
          directory = ".config/spotify";
          mode = "0700";
        }
        {
          directory = ".config/streamdeck";
          mode = "0700";
        }
        {
          directory = ".config/turborepo";
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
          directory = ".local/share/JetBrains";
          mode = "0700";
        }
        {
          directory = ".local/share/PrismLauncher";
          mode = "0700";
        }
        {
          directory = ".local/share/Steam";
          mode = "0700";
        }
        {
          directory = ".local/share/atuin";
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
          directory = ".local/share/direnv";
          mode = "0700";
        }
        {
          directory = ".local/share/evolution";
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
          directory = ".local/share/icc";
          mode = "0700";
        }
        {
          directory = ".local/share/keyrings";
          mode = "0700";
        }
        {
          directory = ".local/share/nautilus";
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
          directory = ".local/share/turborepo";
          mode = "0700";
        }
        {
          directory = ".local/share/vulkan";
          mode = "0700";
        }
        {
          directory = ".local/share/zsh";
          mode = "0700";
        }

        {
          directory = ".local/state/nvim";
          mode = "0700";
        }
        {
          directory = ".local/state/wireplumber";
          mode = "0700";
        }

        {
          directory = ".fleet";
          mode = "0700";
        }

        {
          directory = ".mozilla/firefox";
          mode = "0700";
        }

        "Documents"
        "Downloads"
        "Music"
        "Pictures"
        "Videos"

        {
          directory = "code";
          mode = "0700";
        }
      ];
    };
  };
}
