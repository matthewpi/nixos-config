{
  flavour,
  pkgs,
  ...
}: {
  programs.bottom = {
    enable = true;

    settings =
      {}
      // builtins.fromTOML (builtins.readFile
        (pkgs.fetchFromGitHub
          {
            owner = "catppuccin";
            repo = "bottom";
            rev = "c0efe9025f62f618a407999d89b04a231ba99c92";
            hash = "sha256-VaHX2I/Gn82wJWzybpWNqU3dPi3206xItOlt0iF6VVQ=";
          }
          + /themes/${flavour}.toml));
  };
}
