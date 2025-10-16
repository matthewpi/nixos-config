{
  config,
  lib,
  pkgs,
  ...
}: let
  grammars = {
    tree-sitter-caddyfile = rec {
      url = "https://github.com/caddyserver/tree-sitter-caddyfile";
      rev = "b04bdb4ec53e40c44afbf001e15540f60a296aef";
      hash = "sha256-WaCWKq3wqjhWdsUd2vAT/JPqaxbHhOsaZrCg6MeXZZw=";
      fetchSubmodules = false;
      src = pkgs.fetchgit {inherit url rev hash fetchSubmodules;};
      generate = true;
    };

    tree-sitter-d2 = rec {
      url = "https://github.com/ravsii/tree-sitter-d2";
      rev = "f40a9fa426d55a03cedd17475e4d6affe755a1ae";
      hash = "sha256-pKJ2hsSnIjoUunN8ZjWiinb/mt07WQ9AURc708ENHtY=";
      fetchSubmodules = false;
      src = pkgs.fetchgit {inherit url rev hash fetchSubmodules;};
    };
  };

  builtGrammars = lib.mapAttrs (name: grammar:
    pkgs.tree-sitter.buildGrammar {
      inherit (pkgs.tree-sitter) version;
      language = grammar.language or name;
      src = grammar.src;
      location = grammar.location or null;
      generate = grammar.generate or false;
    })
  grammars;

  linkedGrammars = pkgs.runCommand "grammars" {} ("mkdir \"$out\"\n"
    + (
      lib.concatStrings (
        lib.mapAttrsToList (name: grammar: "ln -s ${grammar.src} \"$out\"/${name}\n")
        grammars
      )
    ));
in {
  xdg.configFile."tree-sitter/config.json".source = (pkgs.formats.json {}).generate "tree-sitter-config.json" {
    parser-directories = [
      pkgs.tree-sitter.grammars
      linkedGrammars
    ];
  };

  programs.neovim = {
    enable = true;

    extraConfig = ''
      filetype plugin indent on

      syntax on

      :set nu
    '';

    extraLuaConfig = ''
      -- Set default file encodings
      vim.opt.encoding = "utf-8"
      vim.opt.fileencoding = "utf-8"

      -- Enable active line highlighting
      vim.opt.cursorline = true

      -- Disable folding by default
      vim.opt.foldlevel = 99

      -- Disable netrw (recommended by telescope)
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      -- Enable 24-bit colors
      vim.opt.termguicolors = true

      require("catppuccin").setup({
        compile_path = vim.fn.stdpath "cache" .. "/catppuccin",

        flavour = "${config.catppuccin.flavor}",
        term_colors = true,
        transparent_background = true,

        integrations = {
          barbar = true,
          cmp = true,
          coc_nvim = true,
          dropbar = {
            enabled = true,
            color_mode = true,
          },
          indent_blankline = {
            enabled = true,
            colored_indent_levels = false,
            scope_color = "text",
          },
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { "italic" },
              hints = { "italic" },
              warnings = { "italic" },
              information = { "italic" },
            },
            underlines = {
              errors = { "underline" },
              hints = { "underline" },
              warnings = { "underline" },
              information = { "underline" },
            },
            inlay_hints = {
              background = true,
            },
          },
          notify = true,
          nvimtree = true,
          telescope = {
            enabled = true,
          },
          treesitter = true,
          treesitter_context = true,
        },

        custom_highlights = function(C)
          return {
            CmpItemKindSnippet = { fg = C.base, bg = C.mauve },
            CmpItemKindKeyword = { fg = C.base, bg = C.red },
            CmpItemKindText = { fg = C.base, bg = C.teal },
            CmpItemKindMethod = { fg = C.base, bg = C.blue },
            CmpItemKindConstructor = { fg = C.base, bg = C.blue },
            CmpItemKindFunction = { fg = C.base, bg = C.blue },
            CmpItemKindFolder = { fg = C.base, bg = C.blue },
            CmpItemKindModule = { fg = C.base, bg = C.blue },
            CmpItemKindConstant = { fg = C.base, bg = C.peach },
            CmpItemKindField = { fg = C.base, bg = C.green },
            CmpItemKindProperty = { fg = C.base, bg = C.green },
            CmpItemKindEnum = { fg = C.base, bg = C.green },
            CmpItemKindUnit = { fg = C.base, bg = C.green },
            CmpItemKindClass = { fg = C.base, bg = C.yellow },
            CmpItemKindVariable = { fg = C.base, bg = C.flamingo },
            CmpItemKindFile = { fg = C.base, bg = C.blue },
            CmpItemKindInterface = { fg = C.base, bg = C.yellow },
            CmpItemKindColor = { fg = C.base, bg = C.red },
            CmpItemKindReference = { fg = C.base, bg = C.red },
            CmpItemKindEnumMember = { fg = C.base, bg = C.red },
            CmpItemKindStruct = { fg = C.base, bg = C.blue },
            CmpItemKindValue = { fg = C.base, bg = C.peach },
            CmpItemKindEvent = { fg = C.base, bg = C.blue },
            CmpItemKindOperator = { fg = C.base, bg = C.blue },
            CmpItemKindTypeParameter = { fg = C.base, bg = C.blue },
          }
        end,
      })

      vim.notify = require("notify")

      require("nvim-treesitter.configs").setup({
        parser_install_dir = "/home/matthew/.cache/tree-sitter",
        auto_install = false,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      })
      vim.opt.runtimepath:append("/home/matthew/.cache/tree-sitter")

      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

      vim.filetype.add({
        filename = {
          ["Caddyfile"] = "caddyfile",
        },
        extension = {
          caddyfile = "caddyfile",
          Caddyfile = "caddyfile",
        },
      })

      vim.filetype.add({
        extension = {
          d2 = "d2",
        },
      })

      require("treesitter-context").setup({
        enable = true,
      })

      -- indent-blankline-nvim
      require("ibl").setup({
        indent = {
          char = "▏",
        },
        scope = {
          enabled = false,
        },
      })

      require("nvim-tree").setup({
        disable_netrw = true,
        hijack_netrw = true,
        hijack_cursor = true,

        git = {
          enable = false,
          ignore = true,
        },

        view = {
          width = 36,
        },
      })

      require("lualine").setup({
        options = {
          theme = "catppuccin",
        },
      })

      -- Add additional capabilities supported by nvim-cmp
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      vim.lsp.config('buf_ls', {
        cmd = { "${lib.getExe pkgs.buf}", "beta", "lsp" },
        capabilities = capabilities,
      })

      vim.lsp.config('gopls', {
        cmd = { "${lib.getExe pkgs.gopls}" },
        capabilities = capabilities,
        settings = {
          analyses = {
            unreachable  = false,
            unusedparams = true,
          },
          staticcheck = true,
          gofumpt = true,
        },
      })
      vim.lsp.config('nixd', {
        cmd = { "${lib.getExe pkgs.nixd}" },
        capabilities = capabilities,
      })
      -- vim.lsp.config('rust_analyzer', {
      --   cmd = { "''${lib.getExe pkgs.rust-analyzer}" },
      --   capabilities = capabilites,
      -- })
      vim.lsp.config('ts_ls', {
        cmd = { "${lib.getExe pkgs.nodePackages.typescript-language-server}", "--stdio" },
        capabilities = capabilities,
      })

      local cmp = require("cmp")
      local lspkind = require("lspkind")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()
      cmp.setup({
        snippet = {
          expand = function (args)
            require("luasnip").lsp_expand(args.body)
          end
        },

        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function (fallback)
            -- This little snippet will confirm with tab, and if no entry is selected, will confirm the first item
            if cmp.visible() then
              local entry = cmp.get_selected_entry()
              if not entry then
                cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
              else
                cmp.confirm()
              end
            else
              fallback()
            end
          end, {"i","s","c",}),
        }),

        sources = {
          { name = "nvim_lsp" },
          { name = "nvim_lsp_signature_help" },
          --{ name = "luasnip" },
          { name = "path" },
        },

        window = {
          completion = {
            --winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
            col_offset = -3,
            side_padding = 0,
          },

          documentation = cmp.config.window.bordered({
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
          }),
        },

        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(entry, vim_item)
            local kind = lspkind.cmp_format({
              mode = "symbol_text",
              maxwidth = 50,
            })(entry, vim_item)

            local strings = vim.split(kind.kind, "%s", { trimempty = true })

            kind.kind = " " .. (strings[1] or "") .. " "
            kind.menu = "    (" .. (strings[2] or "") .. ")"

            return kind
          end,
        },

        view = {
          entries = { name = "custom", selection_order = "near_cursor" },
        },

        experimental = {
          ghost_text = true,
        },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline({}),
        sources = {
          { name = "cmdline" },
          { name = "cmdline_history" },
          { name = "path" },
        },
      })

      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline({}),
        sources = {
          { name = "buffer" },
        },
      })

      require("barbar").setup({
        animation = false,
        sidebar_filetypes = {
          NvimTree = true,
        },
      })

      -- Handle opening nvim-tree
      local function open_nvim_tree(data)
        local directory = vim.fn.isdirectory(data.file) == 1
        if not directory then
          return
        end

        vim.cmd.cd(data.file)
        require("nvim-tree.api").tree.open()
      end

      vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

      -- setup must be called before loading
      vim.cmd.colorscheme "catppuccin"
    '';

    plugins = with pkgs.vimPlugins; [
      barbar-nvim
      catppuccin-nvim
      cmp-buffer
      cmp-cmdline
      cmp-cmdline-history
      cmp-buffer
      cmp_luasnip
      cmp-nvim-lsp
      cmp-nvim-lsp-signature-help
      cmp-path
      dropbar-nvim
      editorconfig-vim
      indent-blankline-nvim
      lspkind-nvim
      lualine-nvim
      luasnip
      nvim-cmp
      nvim-lspconfig
      nvim-notify
      nvim-web-devicons
      nvim-tree-lua
      nvim-treesitter
      (nvim-treesitter.withPlugins (_: nvim-treesitter.allGrammars ++ (lib.attrValues builtGrammars)))
      nvim-treesitter-context
      plenary-nvim
      telescope-nvim
      telescope-fzf-native-nvim
      vim-lastplace
    ];

    extraPackages = with pkgs; [
      fd
      gcc
      ripgrep
      tree-sitter
    ];

    withNodeJs = true;
    withRuby = false;

    defaultEditor = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };
}
