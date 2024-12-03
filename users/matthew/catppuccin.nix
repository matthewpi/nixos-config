{inputs, ...}: {
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin
  ];

  catppuccin = {
    accent = "peach";
    flavor = "mocha";
  };

  home.pointerCursor = {
    size = 32;
    gtk.enable = true;
  };

  catppuccin.pointerCursor = {
    enable = true;
    accent = "dark";
  };

  programs.alacritty.catppuccin.enable = true;

  programs.bat.catppuccin.enable = true;

  programs.bottom.catppuccin.enable = true;

  programs.fzf.catppuccin.enable = true;

  programs.hyprlock.catppuccin.enable = true;

  programs.k9s.catppuccin.enable = true;

  programs.starship.catppuccin.enable = true;

  programs.tmux.catppuccin.enable = true;

  programs.zsh.syntaxHighlighting.catppuccin.enable = true;

  wayland.windowManager.hyprland.catppuccin.enable = true;

  # QT Theming
  qt = {
    enable = true;
    style.name = "kvantum";
    platformTheme.name = "kvantum";
    style.catppuccin = {
      enable = true;
      apply = true;
    };
  };
}
