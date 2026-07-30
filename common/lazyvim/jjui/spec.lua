return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>jj",
      function()
        Snacks.terminal({ "jjui" }, { cwd = LazyVim.root.get() })
      end,
      desc = "jjui (Root Dir)",
    },
    {
      "<leader>jJ",
      function()
        Snacks.terminal({ "jjui" })
      end,
      desc = "jjui (cwd)",
    },
  },
}
