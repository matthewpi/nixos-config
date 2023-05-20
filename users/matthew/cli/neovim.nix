{
  flavour,
  pkgs,
  ...
}: {
  programs.neovim = {
    enable = true;

    extraConfig = ''
      filetype plugin indent on

      set encoding=utf-8
      set fileencoding=utf-8

      syntax on

      :set nu
    '';

    extraLuaConfig = ''
      require("catppuccin").setup({
        compile_path = vim.fn.stdpath "cache" .. "/catppuccin",

        flavour = "${flavour}",
        transparent_background = true,
      })

      -- setup must be called before loading
      vim.cmd.colorscheme "catppuccin"
    '';

    plugins = with pkgs.vimPlugins; [
      catppuccin-nvim
      vim-lastplace
      vim-nix
    ];

    defaultEditor = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };
}
