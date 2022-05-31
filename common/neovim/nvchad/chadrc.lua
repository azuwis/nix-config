local M = {}

M.ui = {
  theme = "nord",
}

M.mappings = {
  general = {
    n = {
      ["<leader>fq"] = { "<cmd> :wq <CR>", "   Save and quit" },
      ["<leader>fs"] = { "<cmd> :update <CR>", "   Save" },
      ["<leader>gg"] = { "<cmd> :Neogit <CR>", "  Neogit" },
    },
  },
}

M.plugins = {
  options = {
    lspconfig = {
      setup_lspconf = "custom.lspconfig",
    },
  },

  override = {
    ["akinsho/bufferline.nvim"] = {
      options = {
        show_buffer_close_icons = false,
      },
    },
    ["nvim-treesitter/nvim-treesitter"] = {
      ensure_installed = {
        "hcl",
        "lua",
        "nix",
        "vim",
        "yaml",
      },
    },
  },

  remove = {
    "lewis6991/impatient.nvim",
    "williamboman/nvim-lsp-installer",
  },

  user = require "custom.plugins",
}

return M
