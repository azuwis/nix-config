local M = {}

M.ui = {
  theme = "nord",
}

M.mappings = {
  general = {
    n = {
      ["<leader>fq"] = { "<cmd> :wq <CR>", "Save and quit" },
      ["<leader>fs"] = { "<cmd> :update <CR>", "Save" },
      ["<leader>gg"] = { "<cmd> :Neogit <CR>", "Neogit" },
    },
  },
}

M.plugins = require "custom.plugins"

return M
