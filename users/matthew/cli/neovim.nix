{
  flavour,
  lib,
  pkgs,
  ...
}: {
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

        flavour = "${flavour}",
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
            --CmpItemKindCopilot = { fg = C.base, bg = C.teal },
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
      parser_config.caddyfile = {
        install_info = {
          url = "~/code/caddyserver/tree-sitter-caddyfile",
          files = {"src/parser.c"},
          branch = "master",
          generate_requires_npm = false,
          requires_generate_from_grammar = false,
        },
      }

      vim.filetype.add({
        filename = {
          ["Caddyfile"] = "caddyfile",
        },
        extension = {
          caddyfile = "caddyfile",
          Caddyfile = "caddyfile",
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

      local lspconfig = require('lspconfig')

      lspconfig.bufls.setup({
        capabilities = capabilities,
        cmd = { "${lib.getExe' pkgs.buf-language-server "buf-language-server"}" },
      })
      lspconfig.gopls.setup({
        capabilities = capabilities,
        cmd = { "${lib.getExe pkgs.gopls}" },
        settings = {
          analyses = {
            unreachable  = false,
            unusedparams = true,
          },
          staticcheck = true,
          gofumpt = true,
        },
      })
      lspconfig.nixd.setup({
        capabilities = capabilities,
        cmd = { "${lib.getExe pkgs.nixd}" },
      })
      lspconfig.rust_analyzer.setup({
        capabilities = capabilites,
        cmd = { "${lib.getExe pkgs.rust-analyzer}" },
      })
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        cmd = { "${lib.getExe pkgs.nodePackages.typescript-language-server}", "--stdio" },
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

      --require("mini.comment").setup()

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
      # dropbar requires neovim 0.10 (aka nightly)
      dropbar-nvim
      editorconfig-vim
      indent-blankline-nvim
      lspkind-nvim
      lualine-nvim
      luasnip
      #mini-nvim
      nvim-cmp
      nvim-lspconfig
      nvim-notify
      nvim-web-devicons
      nvim-tree-lua
      nvim-treesitter
      nvim-treesitter.withAllGrammars
      nvim-treesitter-context
      plenary-nvim
      telescope-nvim
      telescope-fzf-native-nvim
      vim-lastplace
    ];

    extraPackages = with pkgs; [
      gcc
      tree-sitter
      fd
      ripgrep
    ];

    withNodeJs = true;
    withRuby = false;

    defaultEditor = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };
}
