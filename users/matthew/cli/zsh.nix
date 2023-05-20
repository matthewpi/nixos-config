{
  lib,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableVteIntegration = true;

    defaultKeymap = "emacs";
    dotDir = ".config/zsh";

    # Enable our custom fast-syntax-highlighting plugin
    initExtra = ''
      source ${pkgs.fast-syntax-highlighting}/share/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

      source /home/matthew/.config/op/plugins.sh
    '';

    # While we use atuin, we also want regular zsh history as it works with zsh-autosuggestions
    history = {
      extended = true;
      ignoreDups = true;
      ignoreSpace = true;

      path = "/persist/home/matthew/.local/share/zsh/history";
      save = 10000;
      share = true;
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
