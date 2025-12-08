local icons = require("icons")

local front_app = sbar.add("item", "front_app", {
  icon = {
    drawing = false,
  },
})

front_app:subscribe("front_app_switched", function(env)
  front_app:set({
    label = icons.apps[env.INFO] or env.INFO:gsub("^%l", string.upper),
  })
end)
