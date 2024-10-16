return {
  "julienvincent/hunk.nvim",
  cmd = { "DiffEditor" },
  config = function()
    require("hunk").setup({
      ui = {
        tree = {
          width = 30,
        },
      },
    })
  end,
}
