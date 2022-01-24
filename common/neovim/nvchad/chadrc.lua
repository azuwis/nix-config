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
  default_plugin_config_replace = {
    bufferline = {
      options = {
        show_buffer_close_icons = false,
        show_close_icon = false,
      },
    },
  },
  options = {
    lspconfig = {
      setup_lspconf = "custom.lspconfig",
    },
  },
}

return M
