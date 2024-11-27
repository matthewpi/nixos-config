{pkgs, ...}: {
  home.packages = with pkgs; [
    alejandra
    d2
    delve
    emmet-language-server
    eslint
    golangci-lint
    gopls
    go-tools
    (pkgs.runCommand "json-language-server" {} ''
      mkdir -p "$out"/bin
      ln -s ${lib.getExe nodePackages.vscode-json-languageserver} "$out"/bin/json-language-server
      ln -s ${lib.getExe nodePackages.vscode-json-languageserver} "$out"/bin/vscode-json-languageserver
    '')
    nil
    nixd
    nodejs
    package-version-server
    phpactor
    protols
    nodePackages.prettier
    rust-analyzer
    simple-completion-language-server
    tailwindcss-language-server
    taplo
    # typescript-language-server
    vtsls
    vue-language-server
    yaml-language-server
  ];

  programs.zed-editor = {
    enable = true;

    extensions = [
      "assembly"
      "bitbake"
      "blade"
      "capnp"
      "catppuccin"
      "csv"
      "cue"
      "d2"
      "dockerfile"
      "emmet"
      "env"
      "git-firefly"
      "golangci-lint"
      "gosum"
      # "graphql"
      "helm"
      "html"
      "http"
      "ini"
      "jinja2"
      "just"
      "log"
      "make"
      "meson"
      "nix"
      "nu"
      "php"
      "proto"
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

    userKeymaps = [];

    userSettings = {
      auto_update = false;
      base_keymap = "VSCode";

      theme = "Catppuccin Mocha";

      buffer_font_family = "MonaspiceNe Nerd Font";
      buffer_font_size = 12;

      ui_font_family = ".SystemUIFont";
      ui_font_size = 14;

      load_direnv = "shell_hook";

      ensure_final_newline_on_save = true;

      assistant = {
        version = "2";
        enabled = false;
        button = false;
      };

      features.inline_completion_provider = "none";

      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      file_types = {
        # https://github.com/bajrangCoder/zed-laravel-blade
        Blade = ["*.blade.php"];
      };

      lsp = {
        emmet-language-server.binary.path_lookup = true; # This option is ignored.
        eslint.binary.path_lookup = true;

        # graphql.binary.path_lookup = true;
        nil = {
          binary.path_lookup = true;
          settings.formatting.command = ["alejandra"];
        };
        nixd.binary.path_lookup = true;
        package-version-server.binary.path_lookup = true;
        phpactor.binary.path_lookup = true;
        prettier.binary.path_lookup = true;
        protobuf-language-server.binary.path = "protols"; # Use `protols` instead of `protobuf-language-server`.
        simple-completion-language-server.binary.path_lookup = true;
        rust-analyzer.binary.path_lookup = true;
        taplo.binary.path_lookup = true;
        tailwindcss-language-server.binary.path_lookup = true; # This option is ignored.
        typescript-language-server.binary.path_lookup = true; # This option is ignored.

        # Using the `vtsls` path_lookup option causes a binary in the format of
        # `${pkgs.nodejs} ${pkgs.vtsls} ${pkgs.vtsls} --stdio` to get spawned which
        # is very incorrect.
        #
        # ref; https://github.com/zed-industries/zed/blob/597e5f8304ee3ffc74c7a312edf70108e93d59e2/crates/languages/src/vtsls.rs#L279
        # vtsls.binary.path_lookup = true;

        yaml-language-server.binary.path_lookup = true; # This option is ignored.
        json-language-server.binary.path_lookup = true; # This option is ignored.
        vscode-json-languageserver.binary.path_lookup = true; # This option is ignored.
      };
    };
  };
}
