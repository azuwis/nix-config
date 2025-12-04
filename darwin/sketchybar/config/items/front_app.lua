local front_app = sbar.add("item", {
  icon = {
    drawing = false,
  },
})

front_app:subscribe("front_app_switched", function(env)
  front_app:set({
    label = env.INFO:gsub("^%l", string.upper),
  })
end)
