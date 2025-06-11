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
    ++ lib.optional hmConfig.programs.ags.enable ".cache/ags"
    ++ lib.optional hmConfig.programs.atuin.enable ".local/share/atuin"
    ++ lib.optional hmConfig.programs.bat.enable ".cache/bat"
    ++ lib.optionals hmConfig.programs.direnv.enable [
      ".cache/direnv"
      ".local/share/direnv"
    ]
    ++ lib.optionals hmConfig.programs.firefox.enable [
      ".cache/mozilla"
      ".mozilla/firefox"
    ]
    ++ lib.optional hmConfig.programs.gh.enable ".config/gh"
    ++ lib.optionals hmConfig.programs.neovim.enable [
      ".cache/nvim"
      ".local/state/nvim"
    ]
    ++ lib.optional hmConfig.programs.ssh.enable ".cache/ssh"
    ++ lib.optional hmConfig.programs.starship.enable ".cache/starship"
    ++ lib.optional hmConfig.programs.vscode.enable ".config/VSCodium"
    ++ lib.optional hmConfig.programs.zed-editor.enable ".local/share/zed"
    ++ lib.optional hmConfig.programs.zsh.enable ".local/share/zsh"
    ++ lib.optional hmConfig.services.gnome-keyring.enable ".local/share/keyrings"
    ++ lib.optional config.programs.steam.enable ".local/share/Steam"
    ++ lib.optionals isDesktop [
      ".cache/winetricks"
      ".config/streamdeck"
      ".local/share/umu"
      "Games"
    ]
    ++ lib.optional config.services.gvfs.enable ".local/share/gvfs-metadata"
    ++ [
      ".cache/amberol"
      ".cache/buf"
      ".cache/chromium"
      ".cache/containers"
      # ".cache/dconf"
      ".cache/evolution"
      ".cache/fontconfig"
      ".cache/golangci-lint"
      ".cache/go-build"
      ".cache/gstreamer-1.0"
      ".cache/hoppscotch-desktop"
      ".cache/mesa_shader_cache"
      ".cache/nix"
      ".cache/nixpkgs-review"
      ".cache/npm"
      ".cache/pnpm"
      # ".cache/tracker3"
      ".cache/tree-sitter"
      ".cache/turbo"

      ".config/1Password"
      ".config/Flipper Devices Inc"
      ".config/Freelens"
      ".config/Ledger Live"
      ".config/Slack"
      ".config/attic"
      ".config/aws"
      ".config/chromium"
      ".config/discord"
      ".config/easyeffects"
      ".config/evolution"
      ".config/go"
      ".config/io.hoppscotch.desktop"
      ".config/kubernetes"
      ".config/libreoffice"
      ".config/moonlight-mod"
      ".config/nautilus"
      ".config/nix"
      ".config/obsidian"
      ".config/op"
      ".config/rclone"
      ".config/sh.cider.genten"
      ".config/turborepo"
      ".config/vesktop"

      # Kubernetes
      {
        directory = ".kube";
        mode = "0700";
      }

      ".local/share/PrismLauncher"
      ".local/share/cargo"
      ".local/share/containers"
      ".local/share/evolution"
      ".local/share/go"
      ".local/share/gnupg"
      ".local/share/hoppscotch-desktop"
      ".local/share/icc"
      ".local/share/k9s"
      ".local/share/nautilus"
      ".local/share/npm"
      ".local/share/obsidian"
      ".local/share/pnpm"
      ".local/share/sounds"
      ".local/share/step"
      ".local/share/turborepo"
      ".local/share/vulkan"
      ".local/share/wordbook"

      ".local/state/astal"
      ".local/state/home-manager"
      ".local/state/nix"
      ".local/state/wireplumber"

      "Documents"
      "Downloads"
      "Music"
      "Pictures"
      "Videos"
    ];
}
