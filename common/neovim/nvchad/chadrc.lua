local M = {}

M.ui = {
  theme = "nord",
}

M.mappings = {}
M.mappings.plugins = {
  comment = {
    toggle = "gc",
  },
  telescope = {
    find_files = "<leader><leader>",
  },
}

M.plugins = {
  options = {
    lspconfig = {
      setup_lspconf = "custom.lspconfig",
    },
  },
}

return M
