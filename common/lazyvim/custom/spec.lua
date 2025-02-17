return {
  { import = "lazyvim.plugins.extras.coding.mini-surround" },

  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = [[
███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗
████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║
██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║
██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║
██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║
╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝]],
        },
      },
      indent = { animate = { enabled = false } },
      scroll = { enabled = false },
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
      presets = {
        lsp_doc_border = true,
      },
      routes = {
        {
          filter = {
            event = "notify",
            error = true,
            find = "nixd: %-32001:",
          },
          opts = { skip = true },
        },
      },
      views = {
        mini = {
          timeout = 3500,
        },
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
