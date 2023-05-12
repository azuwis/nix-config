local M = {}

M.ui = {
  theme = "nord",
  tabufline = {
    overriden_modules = function()
      return {
        buttons = function()
          return ""
        end,
      }
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

M.lazy_nvim = {
  dev = {
    path = "@plugins@/pack/myNvchadPackages/start/",
    patterns = { "." },
  },
  performance = {
    reset_packpath = false,
    rtp = {
      reset = false,
    },
  },
}

M.plugins = "custom.plugins"

return M
