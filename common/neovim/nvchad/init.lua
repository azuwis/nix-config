local customPlugins = require "core.customPlugins"
customPlugins.add(function(use)
  use {
    "TimUntersberger/neogit",
    cmd = {
      "Neogit",
    },
    requires = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    config = function()
      require("neogit").setup {
        disable_commit_confirmation = true,
        signs = {
          section = { "", "" },
          item = { "", "" },
          hunk = { "", "" },
        },
        integrations = {
          diffview = true,
        },
      }
    end,
  }

  use {
    "kristijanhusak/orgmode.nvim",
    after = "nvim-treesitter",
    config = function()
      local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
      parser_config.org = {
        install_info = {
          url = 'https://github.com/milisims/tree-sitter-org',
          revision = 'f110024d539e676f25b72b7c80b0fd43c34264ef',
          files = {'src/parser.c', 'src/scanner.cc'},
        },
        filetype = 'org',
      }
      require'nvim-treesitter.configs'.setup {
        -- If TS highlights are not enabled at all, or disabled via `disable` prop, highlighting will fallback to default Vim syntax highlighting
        highlight = {
          enable = true,
          disable = {'org'}, -- Remove this to use TS highlighter for some of the highlights (Experimental)
          additional_vim_regex_highlighting = {'org'}, -- Required since TS highlighter doesn't support all syntax features (conceal)
        },
        ensure_installed = {'org'}, -- Or run :TSUpdate org
      }
      require("orgmode").setup {}
    end,
  }
end)

local map = require("core.utils").map
map("n", "<leader>gg", ":Neogit <CR>")
