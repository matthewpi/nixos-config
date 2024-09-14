{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    enableExtensionUpdateCheck = true;
    enableUpdateCheck = false;
    mutableExtensionsDir = false;

    extensions = with pkgs.vscode-extensions;
      [
        # formulahendry.auto-close-tag # Auto Close Tag
        formulahendry.auto-rename-tag # Auto Rename Tag
        mads-hartmann.bash-ide-vscode # Bash IDE
        bungcip.better-toml # Better TOML
        matthewpi.caddyfile-support # Caddyfile Support
        catppuccin.catppuccin-vsc # Catppuccin for VSCode
        catppuccin.catppuccin-vsc-icons # Catppuccin Icons for VSCode
        # streetsidesoftware.code-spell-checker # Code Spell Checker
        asdine.cue # Cue
        ms-azuretools.vscode-docker # Docker
        mikestead.dotenv # DotENV
        mkhl.direnv # direnv
        editorconfig.editorconfig # EditorConfig for VS Code
        # usernamehw.errorlens # Error Lens
        dbaeumer.vscode-eslint # ESLint
        file-icons.file-icons # file-icons
        #github.copilot # GitHub Copilot; TODO: enable?
        #github.vscode-github-actions # GitHub Actions
        eamodio.gitlens # GitLens — Git supercharged
        golang.go # Go
        hashicorp.terraform # HashiCorp Terraform
        ms-kubernetes-tools.vscode-kubernetes-tools # Kubernetes
        davidanson.vscode-markdownlint # markdownlint
        jnoortheen.nix-ide # Nix IDE
        christian-kohler.npm-intellisense # npm Intellisense
        christian-kohler.path-intellisense # Path Intellisense
        bmewburn.vscode-intelephense-client # PHP Intelephense
        esbenp.prettier-vscode # Prettier - Code formatter
        rust-lang.rust-analyzer # rust-analyzer
        tailscale.vscode-tailscale # Tailscale
        bradlc.vscode-tailwindcss # Tailwind CSS IntelliSense
        # vue.volar # Vue - Official
        vscode-icons-team.vscode-icons # vscode-icons
        zxh404.vscode-proto3 # vscode-proto3
        redhat.vscode-xml # XML
        redhat.vscode-yaml # YAML
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        # Buf
        {
          name = "vscode-buf";
          publisher = "bufbuild";
          version = "0.6.2";
          sha256 = "sha256-x2yk3J0peTMMV1VuF+eRCOM+I2lWPzwnBch7s4xJ3yA=";
        }
        # Systemd Helper
        {
          name = "vscode-systemd-support";
          publisher = "hangxingliu";
          version = "2.2.0";
          sha256 = "sha256-08pypB6PZk9diwVmHkwuW6SMlpTbw159seuaWALfMlE=";
        }
        # TODO Highlight v2
        {
          name = "vscode-todo-highlight";
          publisher = "jgclark";
          version = "2.0.8";
          sha256 = "sha256-/CctaLcG+dA2Cf69/ACeDKdRLsu/VUGbAxUbyhI0VyA=";
        }
        # Toggle Quotes
        {
          name = "vscode-toggle-quotes";
          publisher = "britesnow";
          version = "0.3.6";
          sha256 = "sha256-Hn3Mk224ePAAnNtkhKMcCil/kTgbonweb1i884Q62rs=";
        }
        # MDC - Markdown Components
        {
          name = "mdc";
          publisher = "Nuxt";
          version = "0.2.0";
          sha256 = "sha256-M/29ZDg1sva9msGgRe6xqpCYDpW6X/BqKxmiJhzeVXQ=";
        }
        # Nuxtr
        {
          name = "nuxtr-vscode";
          publisher = "nuxtr";
          version = "0.2.16";
          sha256 = "sha256-DVoq8zdlJ2ch8PCG34f1PRkILym9XdclUHQ9s2B5OME=";
        }
        # SQLTools
        {
          name = "sqltools";
          publisher = "mtxr";
          version = "0.28.1";
          sha256 = "sha256-PzDbH9pYeIzmMFOkPMsbo5pNGXI6qusaAlwM6sk9s10=";
        }
        # SQLTools MySQL/MariaDB
        {
          name = "sqltools-driver-mysql";
          publisher = "mtxr";
          version = "0.5.1";
          sha256 = "sha256-RVPCjpIW/9T5TC8b0KQAHCCZnXNvTDJMjfsZWUe/nNg=";
        }
        # SQLTools PostgreSQL/Cockroach Driver
        {
          name = "sqltools-driver-pg";
          publisher = "mtxr";
          version = "0.5.1";
          sha256 = "sha256-TZ5KMjSafdJozKuUL6IatHyChk/b4b27JcuOe1Qtnyw=";
        }
        # SQLTools ClickHouse Driver
        {
          name = "sqltools-clickhouse-driver";
          publisher = "ultram4rine";
          version = "0.5.0";
          sha256 = "sha256-uvCTYDBKD/qCZmiGUQjxvUeT1KS9a8U9y/JIdnXhXxM=";
        }
        # Laravel Blade Snippets
        {
          name = "laravel-blade";
          publisher = "onecentlin";
          version = "1.36.1";
          sha256 = "sha256-zOjUrdoBBtSz59/b/n63QByGyQRcOJFe+TMfosktEss=";
        }
        # Vue - Official
        {
          name = "volar";
          publisher = "vue";
          version = "2.0.28";
          sha256 = "sha256-f0nnmQemu6DxveQfJJrZGrj3dOTHhH1wYJGnNJlM6sU=";
        }
      ];

    keybindings = [];

    userSettings = {
      # Editor
      "editor.accessibilitySupport" = "off";
      "editor.fontFamily" = "\"MonaspiceNe Nerd Font\", monospace";
      "editor.fontLigatures" = false;
      # "editor.fontLigatures" = "'ss01', 'ss02', 'ss03', 'ss04', 'ss05', 'ss06', 'ss07', 'ss08', 'calt', 'dlig'";
      "editor.linkedEditing" = true;
      "editor.wordWrap" = "on";
      "editor.wordWrapColumn" = 100;
      "editor.dragAndDrop" = false;
      "editor.snippetSuggestions" = "bottom";
      "editor.formatOnPaste" = false;
      "editor.emptySelectionClipboard" = false;
      "editor.wordSeparators" = "`~!@#%^&*()=+[{]}\\|;:'\",.<>/?";
      "editor.quickSuggestionsDelay" = 0;
      "editor.insertSpaces" = false;
      "editor.rulers" = [80 100 120];
      "editor.fontSize" = 12;

      # Explorer
      "explorer.sortOrder" = "default";
      "explorer.autoRevealExclude" = {
        "**/.direnv" = true;
        "**/.nuxt" = true;
        "**/bower_components" = true;
        "**/node_modules" = true;
        "**/result" = true;
        "**/vendor" = true;
      };

      # Extensions
      "extensions.ignoreRecommendations" = true;
      "extensions.autoCheckUpdates" = false;
      "extensions.autoUpdate" = false;

      # Files
      "files.eol" = "\n";
      "files.autoSave" = "onWindowChange";
      "files.trimTrailingWhitespace" = true;
      "files.trimFinalNewlines" = true;
      "files.insertFinalNewline" = true;
      "files.exclude" = {
        "**/.direnv" = true;
        "**/result" = true;
      };

      # Telemetry
      "telemetry.telemetryLevel" = "off";

      # Terminal
      "terminal.integrated.fontFamily" = "MonaspiceNe Nerd Font";
      "terminal.integrated.gpuAcceleration" = "auto";
      "terminal.integrated.fontSize" = 13;
      "terminal.integrated.lineHeight" = 1.5;
      "terminal.integrated.cursorBlinking" = false;
      "terminal.integrated.cursorStyle" = "line";

      # Updates
      "update.mode" = "none";
      "update.showReleaseNotes" = false;

      # Window
      "window.titleBarStyle" = "custom";

      # Workbench
      "workbench.colorTheme" = "Catppuccin Mocha";
      "workbench.iconTheme" = "catppuccin-mocha";
      "workbench.startupEditor" = "none";
      "workbench.tree.indent" = 16;
      "workbench.enableExperiments" = false;
      "workbench.panel.defaultLocation" = "bottom";

      #
      # Extension Settings
      #

      # Caddyfile Support
      "caddyfile.executable" = lib.getExe pkgs.caddy;

      # Error Lens
      "errorLens.enabledDiagnosticLevels" = ["error" "warning"];

      # GitHub Copilot
      "editor.inlineSuggest.enabled" = true;

      # GitLens
      "gitlens.showWelcomeOnInstall" = false;
      "gitlens.showWhatsNewAfterUpgrades" = false;
      "gitlens.codeLens.enabled" = false;
      "gitlens.statusBar.enabled" = false;

      # Go
      "go.formatTool" = "default";
      "go.lintTool" = "golangci-lint";
      "go.lintOnSave" = "off";
      "go.gopath" = config.home.sessionVariables.GOPATH;
      "go.goroot" = "${pkgs.go_1_22}/share/go";
      "go.toolsManagement.checkForUpdates" = "off";
      "go.toolsManagement.autoUpdate" = false;
      "go.alternateTools" = {
        "dlv" = lib.getExe pkgs.delve;
        "golangci-lint" = lib.getExe' pkgs.golangci-lint "golangci-lint";
        "gopls" = lib.getExe pkgs.gopls;
        "staticcheck" = lib.getExe' pkgs.go-tools "staticcheck";
      };
      "gopls" = {
        "format.gofumpt" = true;
        "ui.semanticTokens" = true;
      };

      # Nix
      # "nix.enableLanguageServer" = true;
      # "nix.formatterPath" = ["nix" "fmt" "--" "-"];
      # "nix.serverPath" = "${lib.getExe pkgs.nixd}";
      "nix.serverSettings" = {
        "nixd" = {};
      };

      # Red Hat Commons
      "redhat.telemetry.enabled" = false;

      # vscode-icons
      "vsicons.dontShowNewVersionMessage" = true;

      #
      # Language Overrides
      #

      "[php]" = {
        # For PHP we also want `$` and `-` as word separators.
        "editor.wordSeparators" = "`~!@#$%^&*()-=+[{]}\\|;:'\",.<>/?";
      };

      #
      # Other
      #

      # JavaScript

      "javascript.updateImportsOnFileMove.enabled" = "never";
    };
  };

  # For whatever reason the default StartupWMClass is set incorrectly, causing duplicate icons
  # to appear in the taskbar.
  xdg.desktopEntries.codium = {
    actions = {
      "new-empty-window" = {
        exec = "codium --new-window %F";
        icon = "vscodium";
        name = "New Empty Window";
      };
    };

    categories = ["Utility" "TextEditor" "Development" "IDE"];
    comment = "Code Editing. Redefined.";
    exec = "codium %F";
    genericName = "Text Editor";
    icon = "vscodium";
    mimeType = ["text/plain" "inode/directory"];
    name = "VSCodium";
    settings = {
      Keywords = "vscode";
      StartupWMClass = "codium-url-handler";
    };
    startupNotify = true;
  };
}
