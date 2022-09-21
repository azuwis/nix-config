return {
  ["neovim/nvim-lspconfig"] = {
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.plugins.lspconfig"
    end,
  },

  ["nvim-treesitter/nvim-treesitter"] = {
    override_options = {
      ensure_installed = {
        "hcl",
        "lua",
        "nix",
        "vim",
        "yaml",
      },
    },
  },

  ["NvChad/ui"] = {
    override_options = {
      tabufline = {
        overriden_modules = function()
          return {
            buttons = function()
              return ""
            end,
          }
        end,
      },
    },
  },

  ["lewis6991/impatient.nvim"] = false,
  ["williamboman/mason.nvim"] = false,

  ["jose-elias-alvarez/null-ls.nvim"] = {
    after = "nvim-lspconfig",
    config = function()
      require "custom.plugins.null-ls"
    end,
  },

  ["sindrets/diffview.nvim"] = {
    requires = "nvim-lua/plenary.nvim",
    after = "plenary.nvim",
  },
  ["TimUntersberger/neogit"] = {
    cmd = {
      "Neogit",
    },
    requires = "nvim-lua/plenary.nvim",
    config = function()
      require("neogit").setup {
        disable_commit_confirmation = true,
        use_magit_keybindings = true,
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
  },

  ["nvim-orgmode/orgmode"] = {
    after = "nvim-treesitter",
    config = function()
      -- Load custom tree-sitter grammar for org filetype
      require('orgmode').setup_ts_grammar()

      -- Tree-sitter configuration
      require'nvim-treesitter.configs'.setup {
        -- If TS highlights are not enabled at all, or disabled via `disable` prop, highlighting will fallback to default Vim syntax highlighting
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = {'org'}, -- Required for spellcheck, some LaTex highlights and code block highlights that do not have ts grammar
        },
        ensure_installed = {'org'}, -- Or run :TSUpdate org
      }
      require("orgmode").setup {}
    end,
  },
}
