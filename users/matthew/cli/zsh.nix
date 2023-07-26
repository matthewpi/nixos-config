{
  config,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableVteIntegration = true;

    defaultKeymap = "emacs";
    dotDir = ".config/zsh";

    initExtra = ''
      source ${pkgs.fast-syntax-highlighting}/share/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

      source /home/matthew/.config/op/plugins.sh
    '';

    initExtraBeforeCompInit = ''
      bindkey "\e[3~" delete-char

      _zsh_autosuggest_strategy_atuin_top() {
        suggestion=$(atuin search --cmd-only --limit 1 --search-mode prefix $1)
      }
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
      ZSH_AUTOSUGGEST_STRATEGY=('atuin_top' 'completion')
      ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE='20'
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
      ll = "ls --almost-all --color=always --group-directories-first --human-readable -l --size -v";

      sudo = "sudo ";
      please = "sudo ";

      cp = "cp -i";
      mv = "mv -i";
      rm = "rm -i";
    };
  };
}
