return {
  { "echasnovski/mini.indentscope", enabled = false },

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
        section_separators = { left = "", right = "" },
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
}
