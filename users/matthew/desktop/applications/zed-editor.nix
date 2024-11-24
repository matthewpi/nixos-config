{
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
      "golangci-lint"
      "gosum"
      "graphql"
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

      buffer_font_family = "MonaspiceNe Nerd Font";
      buffer_font_size = 16;

      ui_font_family = "Inter";
      ui_font_size = 14;

      load_direnv = "shell_hook";

      ensure_final_newline_on_save = true;

      features = {
        copilot = false;
      };

      telemetry = {
        diagnostics = false;
        metrics = false;
      };
    };
  };
}
