{
  config,
  pkgs,
  ...
}: {
  xdg.configFile."tree-sitter/config.json".source = (pkgs.formats.json {}).generate "tree-sitter-config.json" {
    parser-directories = [
      pkgs.tree-sitter.grammars
      "${config.home.homeDirectory}/code/caddyserver"
    ];
  };
}
