local colors = require("colors")
local icons = require("icons")

local function mouse_click(env)
  if env.BUTTON == "right" then
    sbar.exec("yabai -m space --destroy " .. env.SID)
  else
    sbar.exec("yabai -m space --focus " .. env.SID)
  end
end

local function space_selection(env)
  sbar.set(env.NAME, {
    icon = { highlight = env.SELECTED },
    label = { highlight = env.SELECTED },
  })
end

local function space_windows_change(env)
  if env.INFO.space == tonumber(env.SID) then
    sbar.set(env.NAME, {
      icon = {
        color = next(env.INFO.apps) == nil and colors.dim or colors.default,
      },
    })
  end
end

for i = 1, 10, 1 do
  local space = sbar.add("space", "space" .. i, {
    position = "center",
    associated_space = i,
    icon = {
      string = icons.space,
      padding_left = 5,
      padding_right = 5,
    },
    label = {
      drawing = false,
    },
  })

  space:subscribe("mouse.clicked", mouse_click)
  space:subscribe("space_change", space_selection)
  space:subscribe("space_windows_change", space_windows_change)
end
