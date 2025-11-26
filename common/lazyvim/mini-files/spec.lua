return {
  { import = "lazyvim.plugins.extras.editor.mini-files" },

  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
  },

  {
    "folke/snacks.nvim",
    optional = true,
    opts = {
      explorer = {
        replace_netrw = false,
      },
    },
  },

  {
    "nvim-mini/mini.files",
    lazy = false,
    keys = {
      {
        "<leader>e",
        function()
          require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
        end,
        desc = "Open mini.files (directory of current file)",
      },
    },
    opts = {
      options = {
        use_as_default_explorer = true,
      },
      windows = {
        width_focus = 25,
        width_preview = 90,
      },
    },
  },
}
