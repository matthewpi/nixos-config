{
  config,
  inputs,
  isDesktop,
  pkgs,
  ...
}: {
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin
  ];

  catppuccin = {
    accent = "peach";
    flavor = "mocha";
  };

  home.pointerCursor = let
    inherit (config.catppuccin) flavor;
    accent = "dark";
  in {
    # Catppuccin's hyprland module tries to set `HYPRCURSOR_SIZE` to the same
    # as the main cursor, overriding home-manager. To avoid this, we need to
    # manually set the cursor theme so Catppuccin doesn't break anything.
    name = "catppuccin-${flavor}-${accent}-cursors";
    package = pkgs.catppuccin-cursors.${flavor + "Dark"};

    # TODO: this may need to be different for !isDesktop.
    size = 24;

    hyprcursor = {
      enable = true;
      size =
        if isDesktop
        then 32
        else 24;
    };

    gtk.enable = true;
  };

  # See `home.pointerCursor` for why this is commented out.
  # catppuccin.pointerCursor = {
  #   enable = true;
  #   accent = "dark";
  # };

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
