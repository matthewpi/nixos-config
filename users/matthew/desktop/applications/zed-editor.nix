{
  config,
  lib,
  nixosConfig,
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
      go
      golangci-lint
      gopls
      go-tools
      harper
      intelephense
      (runCommand "json-language-server" {} ''
        mkdir -p "$out"/bin
        ln -s ${lib.getExe nodePackages.vscode-json-languageserver} "$out"/bin/json-language-server
        ln -s ${lib.getExe nodePackages.vscode-json-languageserver} "$out"/bin/vscode-json-languageserver
      '')
      nil
      nixd
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

      # Swift
      sourcekit-lsp

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

    userSettings = lib.mergeAttrsList [
      {
        auto_update = false;
        base_keymap = "VSCode";

        hide_mouse = "never";

        theme = {
          mode = "system";
          light = "Catppuccin Latte";
          dark = "Catppuccin Mocha";
        };
        icon_theme = "Catppuccin Mocha";

        buffer_font_family = "Monaspace Neon";
        buffer_font_size = 12;

        # ref; https://github.com/zed-industries/zed/issues/15752
        # buffer_font_features = {
        #   # https://github.com/githubnext/monaspace?tab=readme-ov-file#cv01-cv09-figure-variants
        #   cv01 = 2; # 0 (slash)
        #   # cv02 = 1; # 1
        #   # https://github.com/githubnext/monaspace?tab=readme-ov-file#cv10-cv29-letter-variants
        #   # cv10 = 0; # l i (Neon, Argon, Xenon, Radon)
        #   # cv11 = 0; # j f r t (Neon, Argon)
        #   # https://github.com/githubnext/monaspace?tab=readme-ov-file#cv30-cv59-symbol-variants
        #   # cv30 = 0; # * (vertically aligned)
        #   # cv31 = 0; # * (6-points)
        #   # cv32 = 0; # >= <= (angled lower-line)
        #   # https://github.com/githubnext/monaspace?tab=readme-ov-file#cv60-cv79-optional-ligatures
        #   # cv60 = 0; # <= =>
        #   # cv61 = 0; # []
        #   # cv62 = 0; # @_
        #   calt = true; # Texture Healing
        #   ss01 = true; # === !== =!= =/= /== /= #= == != ~~ =~ !~ ~- -~ &=
        #   ss02 = true; # >= <=
        #   # ss03 = true; # <--> <-> <!-- <-- --> <- -> <~> <~~ ~~> <~ ~>
        #   # ss04 = true; # </ /> </> <>
        #   ss05 = true; # [| |] /\ \/ |> <| <|> {| |}
        #   ss06 = true; # ### +++ &&&
        #   ss07 = true; # -:- =:= :>: :<: ::> <:: :: :::
        #   ss08 = true; # ..= ..- ..< .= .-
        #   ss09 = true; # <=> <<= =>> =<< => << >>
        #   ss10 = true; # #[ #(
        #   liga = true; # ... /// // !! || ;; ;;;
        # };

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
          biome.settings.require_config_file = true;
          eslint.binary.path_lookup = true;
          nil = {
            binary.path_lookup = true;
            settings.formatting.command = ["alejandra"];
          };
          nixd.binary.path_lookup = true;
          package-version-server.binary.path_lookup = true;
          phpactor.binary.path_lookup = true;
          protobuf-language-server.binary = {
            path = "buf";
            arguments = ["beta" "lsp"];
          };
          simple-completion-language-server.binary.path_lookup = true;
          taplo.binary.path_lookup = true;

          # Using the `vtsls` path_lookup option causes a binary in the format of
          # `${pkgs.nodejs} ${pkgs.vtsls} ${pkgs.vtsls} --stdio` to get spawned which
          # is very incorrect.
          #
          # ref; https://github.com/zed-industries/zed/blob/597e5f8304ee3ffc74c7a312edf70108e93d59e2/crates/languages/src/vtsls.rs#L279
          # vtsls.binary.path_lookup = true;

          yaml-language-server = {
            settings.yaml = {
              # Allow yaml-language-server to pull schemas from [JSON Schema Store](https://www.schemastore.org/json/).
              schemaStore.enable = true;
            };
            settings.editor.tabSize = 2;
            settings."[yaml]".editor.tabSize = 2;
          };

          # json-language-server.binary.path_lookup = true; # This option is ignored.
          # vscode-json-languageserver.binary.path_lookup = true; # This option is ignored.
        };

        # Language settings
        languages = {
          Go.format_on_save = "on";
          JSON.format_on_save = "on";

          JavaScript.format_on_save = "on";

          JSX.format_on_save = "on";

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
      }
      (
        if nixosConfig.services.ollama.enable
        then {
          # Use local Ollama as our AI agent.
          agent = {
            version = "2";
            enabled = true;
            button = true;
            default_model = {
              provider = "ollama";
              model = "gemma3:4b";
            };
          };

          language_models.ollama = {
            api_url = "http://localhost:${toString nixosConfig.services.ollama.port}";
            available_models = [
              {
                name = "gemma3:4b";
                display_name = "Gemma 3";
                max_tokens = 32768;
                keep_alive = "15m";
              }
              {
                name = "zeta";
                display_name = "Zed Zeta";
                max_tokens = 32768;
                keep_alive = "5m";
              }
            ];
          };
        }
        else {
          # Disable AI agent.
          agent = {
            version = "2";
            enabled = false;
            button = false;
          };
        }
      )
    ];

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
