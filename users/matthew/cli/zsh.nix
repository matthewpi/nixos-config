{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableVteIntegration = true;

    autosuggestion = {
      enable = true;
      highlight = "fg=8";
      strategy = lib.mkForce ["completion"];
    };

    defaultKeymap = "emacs";
    dotDir = "${config.xdg.configHome}/zsh";

    localVariables = {
      ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE = 48;
      ZSH_AUTOSUGGEST_USE_ASYNC = true;
      ZSH_AUTOSUGGEST_MANUAL_REBIND = true;
    };

    initContent = lib.mkMerge [
      (lib.mkOrder 550 ''
        bindkey "\e[3~" delete-char
      '')
      ''
        # Enable the fast-syntax-highlighting plugin
        source "${pkgs.fast-syntax-highlighting}/share/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
      ''
    ];

    # TODO: remove zsh history entirely, we use atuin instead.
    history = {
      extended = true;
      ignoreDups = true;
      ignoreSpace = true;

      path = "${config.home.homeDirectory}/.local/share/zsh/history";
      save = 1;
      share = false;
    };

    shellAliases = {
      sudo = "sudo ";
      please = "sudo ";

      cp = "cp -i";
      mv = "mv -i";
      rm = "rm -i";

      g = "git";

      n = "nix";
    };
  };
}
