return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    enabled = false,
  },
  {
    "folke/tokyonight.nvim",
    enabled = false,
  },
  {
    "gbprod/nord.nvim",
    opts = {
      on_highlights = function(highlights, colors)
        -- float window
        highlights.NormalFloat = {
          bg = "#292e39",
        }
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
