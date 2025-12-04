local icons = require("icons")

local cal = sbar.add("item", "calendar", {
  icon = icons.calendar,
  label = {
    padding_right = 0,
  },
  position = "right",
  update_freq = 15,
})

local function update()
  local time = os.date("%a %m-%d %H:%M")
  cal:set({ label = time })
end

cal:subscribe({ "forced", "routine" }, update)
