local colors = require("colors")

sbar.bar({
  height = 24,
  color = colors.bg,
  shadow = true,
  sticky = true,
  padding_right = 10,
  padding_left = 10,
  topmost = "window",
})

sbar.default({
  updates = "when_shown",
  icon = {
    font = {
      family = "JetBrainsMono Nerd Font",
      style = "Medium",
      size = 13.0,
    },
    color = colors.default,
    highlight_color = colors.highlight,
    padding_right = 6,
  },
  label = {
    font = {
      family = "JetBrainsMono Nerd Font",
      style = "Medium",
      size = 13.0,
    },
    color = colors.default,
    highlight_color = colors.highlight,
    padding_right = 10,
  },
})

require("items")
