return {
  {
    "gbprod/nord.nvim",
    opts = {
      on_highlights = function(highlights, colors)
        -- mini.indentscope
        highlights.MiniIndentscopeSymbol = {
          link = "Comment",
        }
        -- nvim-treesitter-context
        highlights.TreesitterContextBottom = {
          underline = true,
          sp = colors.polar_night.brightest,
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
