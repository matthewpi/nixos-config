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
    [".cache/ags"]
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
    ++ lib.optionals hmConfig.programs.zed-editor.enable [
      # Harper is used by Zed for spell-checking, we use this directory to store our custom dictionary
      ".config/harper-ls"
      ".local/share/harper-ls"

      ".cache/zed"
      ".local/share/zed"

      ".local/share/rustup"
    ]
    ++ lib.optional hmConfig.programs.zsh.enable ".local/share/zsh"
    ++ lib.optional hmConfig.services.gnome-keyring.enable ".local/share/keyrings"
    ++ lib.optionals config.programs.steam.enable [
      ".cache/protontricks"
      ".local/share/Steam"
    ]
    ++ lib.optionals isDesktop [
      ".cache/polychromatic"
      ".cache/winetricks"
      ".config/streamdeck"
      ".config/polychromatic"
      ".local/share/umu"
      "Games"
    ]
    ++ lib.optional config.services.gvfs.enable ".local/share/gvfs-metadata"
    ++ [
      ".cache/amberol"
      ".cache/buf"
      ".cache/chromium"
      ".cache/containers"
      ".cache/evolution"
      ".cache/fontconfig"
      ".cache/golangci-lint"
      ".cache/go-build"
      ".cache/gstreamer-1.0"
      ".cache/helm"
      ".cache/mesa_shader_cache_db"
      ".cache/nix"
      ".cache/nixpkgs-review"
      ".cache/npm"
      ".cache/pnpm"
      ".cache/radv_builtin_shaders"
      ".cache/supersonic"
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
      ".config/helm"
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
      ".config/supersonic"
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
      ".local/share/io.hoppscotch.desktop"
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
