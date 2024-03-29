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
        formulahendry.auto-close-tag # Auto Close Tag
        formulahendry.auto-rename-tag # Auto Rename Tag
        mads-hartmann.bash-ide-vscode # Bash IDE
        bungcip.better-toml # Better TOML
        matthewpi.caddyfile-support # Caddyfile Support
        catppuccin.catppuccin-vsc # Catppuccin for VSCode
        streetsidesoftware.code-spell-checker # Code Spell Checker
        asdine.cue # Cue
        ms-azuretools.vscode-docker # Docker
        mikestead.dotenv # DotENV
        mkhl.direnv # direnv
        editorconfig.editorconfig # EditorConfig for VS Code
        usernamehw.errorlens # Error Lens
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
        christian-kohler.path-intellisense # Path Intellisense
        esbenp.prettier-vscode # Prettier - Code formatter
        rust-lang.rust-analyzer # rust-analyzer
        tailscale.vscode-tailscale # Tailscale
        bradlc.vscode-tailwindcss # Tailwind CSS IntelliSense
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
          version = "0.5.1";
          sha256 = "sha256-73+VblPnfozEyqdqUJsUjGY6FKYS70keXIpEXS8EvxA=";
        }
        # npm Intellisense
        {
          name = "npm-intellisense";
          publisher = "christian-kohler";
          version = "1.4.4";
          sha256 = "sha256-RLni/Iz2ZIX8/17gArc90ycVU9wPhNBa32Pe47sdGr0=";
        }
        # Systemd Helper
        {
          name = "vscode-systemd-support";
          publisher = "hangxingliu";
          version = "1.0.1";
          sha256 = "sha256-2uMsLQWv06/nYt3F6qu1JLVSJAKdRlsOqSw+K4M38jg=";
        }
        # TODO Highlight
        {
          name = "vscode-todo-highlight";
          publisher = "wayou";
          version = "1.0.5";
          sha256 = "sha256-CQVtMdt/fZcNIbH/KybJixnLqCsz5iF1U0k+GfL65Ok=";
        }
        # Toggle Quotes
        {
          name = "vscode-toggle-quotes";
          publisher = "britesnow";
          version = "0.3.6";
          sha256 = "sha256-Hn3Mk224ePAAnNtkhKMcCil/kTgbonweb1i884Q62rs=";
        }
        # Vue Language Features (Volar)
        {
          name = "volar";
          publisher = "vue";
          version = "1.8.5";
          sha256 = "sha256-AEIQFglW6RiWusiciMUeXgMs+bIERI/oDY6GUEQTPKg=";
        }
        # MDC - Markdown Components
        {
          name = "mdc";
          publisher = "Nuxt";
          version = "0.2.0";
          sha256 = "sha256-M/29ZDg1sva9msGgRe6xqpCYDpW6X/BqKxmiJhzeVXQ=";
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
      "editor.rulers" = [100 120];
      "editor.fontSize" = 12;

      # Explorer
      "explorer.sortOrder" = "default";
      "explorer.autoRevealExcludes" = {
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
      "workbench.iconTheme" = "vscode-icons";
      "workbench.startupEditor" = "none";
      "workbench.tree.indent" = 16;
      "workbench.enableExperiments" = false;
      "workbench.panel.defaultLocation" = "bottom";

      #
      # Extension Settings
      #

      # Caddyfile Support
      "caddyfile.executable" = "${lib.getExe pkgs.caddy}";

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
      "go.goroot" = "${pkgs.go_1_21}/share/go";
      "go.toolsManagement.checkForUpdates" = "off";
      "go.toolsManagement.autoUpdate" = false;
      "go.alternateTools" = {
        "dlv" = "${lib.getExe pkgs.delve}";
        "golangci-lint" = "${lib.getExe' pkgs.golangci-lint "golangci-lint"}";
        "gopls" = "${lib.getExe pkgs.gopls}";
        "staticcheck" = "${pkgs.go-tools}/bin/staticcheck";
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
    };
  };

  # For whatever reason the default StartupWMClass is set incorrectly, causing duplicate icons
  # to appear in the taskbar.
  xdg.desktopEntries.codium = {
    actions = {
      "new-empty-window" = {
        exec = "codium --verbose --new-window %F";
        icon = "vscodium";
        name = "New Empty Window";
      };
    };

    categories = ["Utility" "TextEditor" "Development" "IDE"];
    comment = "Code Editing. Redefined.";
    # For some magical reason adding the `--verbose` flag causes codium to not crash when launched
    # by `systemd-run`. I cannot figure out why, but someone else has reported the exact same
    # issue and solution.
    exec = "codium --verbose %F";
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
