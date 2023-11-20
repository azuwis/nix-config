return {
  {
    "gbprod/nord.nvim",
    opts = {
      on_highlights = function(highlights, colors)
        highlights.TreesitterContextBottom = {
          underline = true,
          sp = colors.polar_night.brightest,
        }
        highlights.MiniIndentscopeSymbol = {
          link = "Comment",
        }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nord",
    },
  },
}
