{
  config,
  flavour,
  inputs,
  outputs,
  pkgs,
  ...
}: {
  # Configure home-manager
  home-manager = {
    useUserPackages = true;
    extraSpecialArgs = {
      inherit flavour inputs outputs;
    };

    users = {
      matthew = import ./matthew/default.nix;
    };
  };

  # Enable zsh
  programs.zsh.enable = true;

  # Allow matthew access to 1Password
  programs._1password-gui.polkitPolicyOwners = ["matthew"];

  # Disable dynamic users
  users.mutableUsers = false;

  # Configure users
  users.users = {
    matthew = {
      isNormalUser = true;
      shell = pkgs.zsh;
      # TODO: conditionally add user to groups depending on if their associated services are enabled
      extraGroups = ["wheel" "corectrl" "libvirtd" "qemu-libvirtd"];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAJ30VI7vAdrs2MDgkNHSQMJt2xBtBLrirVhinSyteeU"
      ];
      passwordFile = config.age.secrets.passwordfile-matthew.path;
    };
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
          directory = ".cache/turbo";
          mode = "0700";
        }

        {
          directory = ".config/1Password";
          mode = "0700";
        }
        {
          directory = ".config/Code";
          mode = "0700";
        }
        {
          directory = ".config/Element";
          mode = "0700";
        }
        {
          directory = ".config/Insomnia";
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
          directory = ".config/Postman";
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
          directory = ".config/op";
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

        # I don't use this but other apps do
        {
          directory = ".gnupg";
          mode = "0700";
        }

        # I hate this, JetBrains uses it to store
        # auth data and agreement to their ToS
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
          directory = ".local/share/JetBrains";
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
          directory = ".lunarclient";
          mode = "0700";
        }
        {
          directory = ".minecraft";
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

  # Add a udev rule for Elgato Stream Deck(s)
  # TODO: figure out why the second udev rule is broken.
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0060|0063|006c|006d", MODE="0660", TAG+="uaccess"
    ACTION=="change", SUBSYSTEM=="power_supply", ATTR{online}=="1" , ATTRS{idVendor}=="046d", ATTRS{idProduct}=="4082", RUN+="${pkgs.libratbag}/bin/ratbagctl 'Logitech MX Master 3' dpi set 400"
  '';
}
