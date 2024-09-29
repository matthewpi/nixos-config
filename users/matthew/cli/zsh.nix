{
  config,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableVteIntegration = true;

    autosuggestion.enable = true;

    defaultKeymap = "emacs";
    dotDir = ".config/zsh";

    initExtra = ''
      # Enable the fast-syntax-highlighting plugin
      source "${pkgs.fast-syntax-highlighting}/share/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"

      # Enable the zsh-titles plugin
      source "${pkgs.zsh-titles}/share/zsh-titles/titles.plugin.zsh"
    '';

    initExtraBeforeCompInit = ''
      bindkey "\e[3~" delete-char

      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
      ZSH_AUTOSUGGEST_STRATEGY=('completion')
      ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE='48'
      ZSH_AUTOSUGGEST_USE_ASYNC='true'
      ZSH_AUTOSUGGEST_MANUAL_REBIND='true'
    '';

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
      ll = let
        ls =
          if pkgs.stdenv.isDarwin
          then "${pkgs.coreutils}/bin/ls"
          else "ls";
      in "${ls} --almost-all --color=always --group-directories-first --human-readable -l --size -v";

      sudo = "sudo ";
      please = "sudo ";

      cp = "cp -i";
      mv = "mv -i";
      rm = "rm -i";
    };
  };
}
