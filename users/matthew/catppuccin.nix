{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin
  ];

  catppuccin = {
    accent = "mauve";
    flavor = "mocha";

    alacritty.enable = true;

    bat.enable = true;

    bottom.enable = true;

    fzf.enable = true;

    ghostty.enable = true;

    hyprland.enable = true;

    hyprlock.enable = true;

    kvantum = {
      enable = true;
      apply = true;
    };

    k9s = {
      enable = true;
      transparent = true;
    };

    starship.enable = true;

    tmux.enable = true;

    zsh-syntax-highlighting.enable = true;
  };

  home.pointerCursor = let
    inherit (config.catppuccin) flavor;
    accent = "dark";
    size = 24;
  in {
    # Catppuccin's hyprland module tries to set `HYPRCURSOR_SIZE` to the same
    # as the main cursor, overriding home-manager. To avoid this, we need to
    # manually set the cursor theme so Catppuccin doesn't break anything.
    name = "catppuccin-${flavor}-${accent}-cursors";
    package = pkgs.catppuccin-cursors.${flavor + "Dark"};
    inherit size;

    hyprcursor = {
      enable = true;
      inherit size;
    };

    gtk.enable = true;
  };

  # See `home.pointerCursor` for why this is commented out.
  # catppuccin.pointerCursor = {
  #   enable = true;
  #   accent = "dark";
  # };

  # QT Theming
  qt = {
    enable = true;
    style.name = "kvantum";
    platformTheme.name = "kvantum";
  };
}
