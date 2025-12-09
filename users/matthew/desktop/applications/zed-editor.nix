{
  config,
  lib,
  pkgs,
  ...
}: {
  # Enable a workaround for a pretty nasty GPU crash.
  #
  # Logs:
  # ```
  # [gpui::platform::blade::blade_renderer] GPU hung
  # [gpui::platform::blade::blade_renderer] there's a known bug with amdgpu/radv, try setting ZED_PATH_SAMPLE_COUNT=0 as a workaround
  # ERROR [gpui::platform::blade::blade_renderer] if that helps you're running into https://github.com/zed-industries/zed/issues/26143
  # ERROR [gpui::platform::blade::blade_renderer] your device information is: DeviceInformation { is_software_emulated: false, device_name: "AMD Radeon RX 7800 XT (RADV NAVI32)", driver_name: "radv", driver_info: "Mesa 25.0.5" }
  # ```
  #
  # ref; https://github.com/zed-industries/zed/issues/26143
  # ref; https://github.com/zed-industries/zed/pull/26890
  home.sessionVariables.ZED_PATH_SAMPLE_COUNT = 0;

  # TODO: why do these need to be installed globally?
  home.packages = with pkgs; [nil nixd];

  programs.zed-editor = {
    enable = true;
    package = pkgs.zed-editor;
    installRemoteServer = true;

    extraPackages = with pkgs; [
      alejandra
      # biome
      clang-tools
      cue
      d2
      delve
      emmet-language-server
      eslint
      config.programs.git.package
      go_1_25
      gopls
      golangci-lint
      (go-tools.override {buildGoModule = pkgs.buildGoLatestModule;})
      harper
      intelephense
      (runCommand "json-language-server" {} ''
        mkdir -p "$out"/bin
        ln -s ${lib.getExe nodePackages.vscode-json-languageserver} "$out"/bin/json-language-server
        ln -s ${lib.getExe nodePackages.vscode-json-languageserver} "$out"/bin/vscode-json-languageserver
      '')
      # nil
      # nixd
      nodejs
      opentofu
      (runCommand "terraform" {} ''
        mkdir -p "$out"/bin
        ln -s ${lib.getExe opentofu} "$out"/bin/terraform
      '')
      tofu-ls
      (runCommand "terraform-ls" {} ''
        mkdir -p "$out"/bin
        ln -s ${lib.getExe tofu-ls} "$out"/bin/terraform-ls
      '')
      package-version-server
      nodePackages.prettier
      python313Packages.python-lsp-server
      rust-analyzer
      simple-completion-language-server
      tailwindcss-language-server
      taplo
      uncrustify
      vala-language-server
      vtsls
      vue-language-server
      yaml-language-server

      # C#
      # omnisharp-roslyn

      # # Swift
      # sourcekit-lsp

      clang
      tree-sitter
      rustup
    ];

    extensions = [
      "assembly"
      "biome"
      "bitbake"
      "blade"
      "capnp"
      "catppuccin"
      "catppuccin-icons"
      "csv"
      "cue"
      "d2"
      "dockerfile"
      "emmet"
      "env"
      "git-firefly"
      "golangci-lint"
      "gosum"
      "harper"
      "helm"
      "html"
      "http"
      "ini"
      "jinja2"
      "just"
      "log"
      "lua"
      "make"
      "meson"
      "nix"
      "nu"
      "php"
      "proto"
      "scheme"
      "scss"
      "snippets"
      "sql"
      "terraform"
      "toml"
      "typst"
      "vala"
      "vue"
      "xml"
      "zig"
    ];

    userSettings = rec {
      auto_update = false;
      base_keymap = "VSCode";

      hide_mouse = "never";

      theme = {
        mode = "system";
        light = "Catppuccin Latte";
        dark = "Catppuccin Mocha";
      };
      icon_theme = "Catppuccin Mocha";

      buffer_font_family = "Monaspace Neon NF";
      buffer_font_size = 12;
      buffer_font_features = {
        # https://github.com/githubnext/monaspace?tab=readme-ov-file#cv01-cv09-figure-variants
        cv01 = 2; # 0 (slash)
        # cv02 = 0; # 1

        # https://github.com/githubnext/monaspace?tab=readme-ov-file#cv10-cv29-letter-variants
        cv10 = 1; # Alternatives for "l i" (Neon, Argon, Xenon, Radon)
        cv11 = 1; # Alternatives for "j f r t" (Neon, Argon)

        # https://github.com/githubnext/monaspace?tab=readme-ov-file#cv30-cv59-symbol-variants
        # cv30 = 0; # * (vertically aligned)
        cv31 = 1; # * (6-points instead of 5)
        # cv32 = 0; # >= <= (angled lower-line)

        # https://github.com/githubnext/monaspace?tab=readme-ov-file#cv60-cv79-optional-ligatures
        # cv60 = 0; # <= =>
        # cv61 = 0; # []
        # cv62 = 0; # @_

        # https://github.com/githubnext/monaspace?tab=readme-ov-file#coding-ligatures
        calt = true; # Texture Healing
        liga = true; # ... /// // !! || ;; ;;;
        ss01 = true; # === !== =!= =/= /== /= #= == != ~~ =~ !~ ~- -~ &=
        ss02 = true; # >= <=
        ss03 = true; # <--> <-> <!-- <-- --> <- -> <~> <~~ ~~> <~ ~>
        ss04 = true; # </ /> </> <>
        ss05 = true; # [| |] /\ \/ |> <| <|> {| |}
        ss06 = true; # ### +++ &&&
        ss07 = true; # -:- =:= :>: :<: ::> <:: :: :::
        ss08 = true; # ..= ..- ..< .= .-
        ss09 = true; # <=> <<= =>> =<< => << >>
        ss10 = true; # #[ #(
      };
      terminal.font_features = buffer_font_features;

      ui_font_family = ".SystemUIFont";
      ui_font_size = 14;

      wrap_guides = [80 100 120];

      load_direnv = "shell_hook";

      # Configure colored indent guides.
      indent_guides.coloring = "indent_aware";

      # Configure inlay hints.
      inlay_hints = {
        enabled = true;
        show_background = false;
      };

      #project_panel.show_diagnostics = "off";

      # Hide the collaboration panel button.
      collaboration_panel.button = false;

      # Configure the Zed journal to open in a properly persisted directory
      # and use 24 hour time.
      journal = {
        path = "/code/matthewpi/journal";
        hour_format = "hour24";
      };

      # Disable Jupyter.
      #
      # NOTE: Zed says `property enabled is not allowed` but it is definitely
      # checked by Zed's source code.
      #
      # ref; https://github.com/zed-industries/zed/blob/ff79b29f3812e8d39763e51af17c9c13e3ebf8f5/crates/repl/src/jupyter_settings.rs#L19
      # ref; https://github.com/zed-industries/zed/blob/ff79b29f3812e8d39763e51af17c9c13e3ebf8f5/crates/editor/src/editor_settings.rs#L705-L707
      jupyter.enabled = false;

      # Ensure files always end with a newline.
      ensure_final_newline_on_save = true;

      # Disable formatting on save by default.
      format_on_save = "off";

      # Use language servers for formatting.
      formatter = "language_server";

      # Fix file type associations.
      file_types = {
        # https://github.com/bajrangCoder/zed-laravel-blade
        Blade = ["*.blade.php"];
      };

      lsp = {
        # Only enable Biome when a `biome.jsonc?` file is present in the project.
        biome.settings.require_config_file = true;

        harper-ls.settings.harper-ls.linters = {
          PunctuationClusters = false;
        };

        # Allow trailing commas for specific JSON files.
        json-language-server.settings.json.schemas = [
          {
            fileMatch = ["bun.lock"];
            schema.allowTrailingCommas = true;
          }
          {
            fileMatch = ["*.jsonc"];
            schema.allowTrailingCommas = true;
          }
        ];

        # Use `alejandra` for formatting with `nil` (Nix Language Server).
        nil.settings.formatting.command = ["alejandra"];

        # Use `buf` as the language server for Protobuf.
        protobuf-language-server.binary = {
          path = "buf";
          arguments = ["beta" "lsp"];
        };

        yaml-language-server = {
          # Allow yaml-language-server to pull schemas from [JSON Schema Store](https://www.schemastore.org/json/).
          settings.yaml.schemaStore.enable = true;

          # Ensure tabs with a size of 2 are always used for YAML.
          settings.editor.tabSize = 2;
          settings."[yaml]".editor.tabSize = 2;
        };
      };

      # Language settings
      languages = {
        Go.format_on_save = "on";
        JSON.format_on_save = "on";
        JavaScript.format_on_save = "on";
        # Nix.format_on_save = "on";
        TypeScript.format_on_save = "on";
        TSX.format_on_save = "on";

        PHP.language_servers = ["intelephense" "!phpactor"];

        "Vue.js" = {
          format_on_save = "on";
          language_servers = ["!tailwindcss-language-server" "vue-language-server"];
        };
      };

      # Disable AI completion.
      features.edit_prediction_provider = "none";

      # Disable completions in comments.
      edit_predictions_disabled_in = ["comment"];

      # Disable telemetry.
      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      # Enable Zed's built-in AI agent.
      agent = {
        enabled = true;
        button = true;
      };
    };

    userKeymaps = [
      {
        context = "Terminal";
        bindings = {
          # Re-use the same keybind that opens the terminal to hide it.
          #
          # TODO: is there a better way to close/toggle the terminal view? This
          # will only work if the terminal is docked at the bottom.
          "ctrl-`" = "workspace::ToggleBottomDock";
          # Allow pasting with Ctrl+V.
          "ctrl-v" = "terminal::Paste";
          # Forward Ctrl+S (used for Atuin to change search mode).
          "ctrl-s" = ["terminal::SendKeystroke" "ctrl-s"];
        };
      }
    ];
  };
}
