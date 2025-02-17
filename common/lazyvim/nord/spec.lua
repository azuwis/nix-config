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
        -- nvim-treesitter-context
        highlights.TreesitterContextBottom = {
          underline = true,
          sp = colors.polar_night.brightest,
        }
        -- snacks.nvim
        highlights.SnacksIndent = {
          link = "Comment",
        }
        highlights.SnacksIndentScope = {
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
