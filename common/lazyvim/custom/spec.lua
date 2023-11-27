return {
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
    "L3MON4D3/LuaSnip",
    optional = true,
    config = function()
      require("luasnip.loaders.from_snipmate").lazy_load()
    end,
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
      stages = "fade",
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
    },
  },

  {
    "folke/neodev.nvim",
    optional = true,
    opts = {
      override = function(root_dir, library)
        if root_dir:find("/etc/nixos") == 1 or root_dir:find(".config/nixpkgs") then
          library.enabled = true
          library.plugins = true
        end
      end,
    },
  },

  {
    "folke/noice.nvim",
    optional = true,
    opts = {
      presets = {
        lsp_doc_border = true,
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {
      max_lines = 1,
    },
  },
}
