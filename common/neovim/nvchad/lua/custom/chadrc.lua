local M = {}

M.ui = {
  theme = "nord",
  tabufline = {
    overriden_modules = function(modules)
      modules[4] = (function()
        return ""
      end)()
    end,
  },
}

M.mappings = {
  general = {
    n = {
      ["<leader>fq"] = { "<cmd> :wq <CR>", "Save and quit" },
      ["<leader>fs"] = { "<cmd> :update <CR>", "Save" },
      ["<leader>fS"] = { "<cmd> :execute ':silent w !sudo tee % > /dev/null' | :edit! <CR>", "Sudo save" },
      ["<leader>gg"] = { "<cmd> :Neogit <CR>", "Neogit" },
      ["<leader><leader>"] = { "<cmd> :Telescope custom find <CR>", "Find" },
    },
  },
}

M.plugins = "custom.plugins"

return M
