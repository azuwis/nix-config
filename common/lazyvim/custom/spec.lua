return {
  { import = "lazyvim.plugins.extras.coding.mini-surround" },

  {
    "nvimdev/dashboard-nvim",
    optional = true,
    opts = {
      config = {
        header = {
          "",
          "",
          "",
          "",
          "",
          "",
          "███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
          "████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
          "██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
          "██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
          "██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
          "╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
          "",
          "",
        },
      },
    },
  },

  {
    "Bilal2453/luvit-meta",
    enabled = false,
  },

  {
    "echasnovski/mini.indentscope",
    optional = true,
    opts = {
      draw = {
        animation = require("mini.indentscope").gen_animation.none(),
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                ignoreDir = { ".direnv" },
              },
            },
          },
        },
      },
    },
  },

  {
    "rcarriga/nvim-notify",
    optional = true,
    opts = {
      render = "compact",
      stages = "static",
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { focusable = false, zindex = 100 })
      end,
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = {
      options = {
        component_separators = "",
        section_separators = { left = "", right = "" },
        -- section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_z = {},
      },
    },
  },

  {
    "folke/noice.nvim",
    optional = true,
    opts = {
      messages = {
        enabled = false,
      },
      presets = {
        lsp_doc_border = true,
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    optional = true,
    opts = {
      max_lines = 1,
    },
  },
}
