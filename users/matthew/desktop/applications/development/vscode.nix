{
  lib,
  pkgs,
  ...
}: {
  # For whatever reason the default StartupWMClass is set incorrectly, causing duplicate icons
  # to appear in the taskbar.
  xdg.desktopEntries.code = {
    actions = {
      "new-empty-window" = {
        exec = "code --new-window %F";
        icon = "vscode";
        name = "New Empty Window";
      };
    };

    categories = ["Utility" "TextEditor" "Development" "IDE"];
    comment = "Code Editing. Redefined.";
    exec = "code %F";
    genericName = "Text Editor";
    icon = "vscode";
    mimeType = ["text/plain" "inode/directory"];
    name = "Visual Studio Code";
    settings = {
      Keywords = "vscode";
      StartupWMClass = "code-url-handler";
    };
    startupNotify = true;
  };

  programs.vscode = {
    enable = true;

    enableExtensionUpdateCheck = true;
    enableUpdateCheck = false;
    mutableExtensionsDir = false;

    extensions = with pkgs.vscode-extensions; [
      #redhat.ansible # Ansible; TODO: package
      formulahendry.auto-close-tag # Auto Close Tag
      formulahendry.auto-rename-tag # Auto Rename Tag
      mads-hartmann.bash-ide-vscode # Bash IDE
      #samuelcolvin.jinjahtml # Better Jinja; TODO: package
      bungcip.better-toml # Better TOML
      matthewpi.caddyfile-support # Caddyfile Support
      catppuccin.catppuccin-vsc # Catppuccin for VSCode
      streetsidesoftware.code-spell-checker # Code Spell Checker
      asdine.cue # Cue
      ms-azuretools.vscode-docker # Docker
      mikestead.dotenv # DotENV
      editorconfig.editorconfig # EditorConfig for VS Code
      usernamehw.errorlens # Error Lens
      dbaeumer.vscode-eslint # ESLint
      file-icons.file-icons # file-icons
      #github.copilot # GitHub Copilot
      github.github-vscode-theme # GitHub Theme
      eamodio.gitlens # GitLens — Git supercharged
      golang.go # Go
      #tim-koehler.helm-intellisense # Helm Intellisense; TODO: package
      hashicorp.terraform # HashiCorp Terraform
      ms-kubernetes-tools.vscode-kubernetes-tools # Kubernetes
      davidanson.vscode-markdownlint # markdownlint
      jnoortheen.nix-ide # Nix IDE
      #christian-kohler.npm-intellisense # npm Intellisense; TODO: package
      christian-kohler.path-intellisense # Path Intellisense
      esbenp.prettier-vscode # Prettier - Code formatter
      #1dot75cm.rpmspec # RPM Spec; TODO: package
      #rust-lang.rust-analyzer # rust-analyzer; TODO: package
      #google.selinux-policy-languages # SELinux Policy; TODO: package
      #hangxingliu.vscode-systemd-support # Systemd Helper; TODO: package
      bradlc.vscode-tailwindcss # Tailwind CSS IntelliSense
      #wayou.vscode-todo-highlight # TODO Highlight; TODO: package
      #britesnow.vscode-toggle-quotes # Toggle Quotes; TODO: package
      vscode-icons-team.vscode-icons # vscode-icons
      zxh404.vscode-proto3 # vscode-proto3
      #vue.volar # Vue Language Features (Volar); TODO: package
      redhat.vscode-xml # XML
      redhat.vscode-yaml # YAML
    ];

    keybindings = [];

    userSettings = {
      # Editor
      "editor.accessibilitySupport" = "off";
      "editor.fontFamily" = "\"Hack Nerd Font Mono\", Menlo, Consolas, \"Liberation Mono\", \"Courier New\", monospace";
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

      # Extensions
      "extensions.ignoreRecommendations" = true;

      # Files
      "files.eol" = "\n";
      "files.autoSave" = "onWindowChange";
      "files.trimTrailingWhitespace" = true;
      "files.trimFinalNewlines" = true;
      "files.insertFinalNewline" = true;

      # Telemetry
      "telemetry.telemetryLevel" = "off";

      # Terminal
      "terminal.integrated.fontFamily" = "Hack Nerd Font Mono";
      "terminal.integrated.gpuAcceleration" = "auto";
      "terminal.integrated.fontSize" = 13;
      "terminal.integrated.lineHeight" = 1.5;
      "terminal.integrated.cursorBlinking" = false;
      "terminal.integrated.cursorStyle" = "line";

      # Updates
      "update.mode" = "none";
      "update.showReleaseNotes" = false;

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

      # GitHub Copilot
      "editor.inlineSuggest.enabled" = true;

      # Go
      "go.formatTool" = "default";
      "go.lintTool" = "golangci-lint";
      "go.lintOnSave" = "off";
      "go.gopath" = "/home/matthew/.local/share/go";
      "go.goroot" = "${pkgs.go_1_20}/share/go";
      "go.toolsManagement.checkForUpdates" = false;
      "go.toolsManagement.autoUpdate" = false;
      "go.alternateTools" = {
        "dlv" = "${pkgs.delve}/bin/dlv";
        "golangci-lint" = "${pkgs.golangci-lint}/bin/golangci-lint";
        "gopls" = "${pkgs.gopls}/bin/gopls";
        "staticcheck" = "${pkgs.go-tools}/bin/staticcheck";
      };
      "gopls" = {
        "format.gofumpt" = true;
      };

      # Nix
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = lib.getExe pkgs.nixd;
      "nix.serverSettings" = {
        "nixd" = {};
      };

      # Red Hat Commons
      "redhat.telemetry.enabled" = false;

      # vscode-icons
      "vsicons.dontShowNewVersionMessage" = true;
    };
  };
}
