return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "ibhagwan/fzf-lua",
      "lewis6991/gitsigns.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "sindrets/diffview.nvim",
    },
    cmd = {
      "Neogit",
    },
    keys = {
      {
        "<leader>gg",
        "<cmd>Neogit<cr>",
        desc = "Neogit",
      },
    },
    config = function()
      require("neogit").setup({
        disable_commit_confirmation = true,
        integrations = {
          diffview = true,
          telescope = true,
        },
        signs = {
          section = { "", "" },
          item = { "", "" },
          hunk = { "", "" },
        },
      })
    end,
  },
}
