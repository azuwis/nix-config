local colors = require("colors")
local icons = require("icons")
local rift = require("rift")
local count = 8
local current = nil
local spaces = {}

local client, err = rift.connect()
if not client then
  print("rift.lua: " .. tostring(err))
  return
end

local function mouse_click(index)
  local resp, send_err = client:send_request(
    string.format([[{"execute_command":{"command":"{\"Reactor\":{\"switch_to_workspace\":%d}}","args":[]}}]], index)
  )
  if not resp then
    print("rift.lua: " .. tostring(send_err))
  end
end

client:subscribe({ "workspace_changed" }, function(env)
  local index = env.DATA.workspace_id.idx - 1
  if index == current then
    return
  end
  if spaces[current] then
    spaces[current]:set({ icon = { highlight = false } })
  end
  if spaces[index] then
    spaces[index]:set({ icon = { highlight = true } })
    current = index
  else
    current = nil
  end
end)

client:subscribe({ "windows_changed" }, function(env)
  local is_empty = next(env.DATA.windows) == nil
  local index = env.DATA.workspace_id.idx - 1
  if index >= 1 and index <= 8 then
    spaces[index]:set({
      icon = {
        color = is_empty and colors.dim or colors.default,
      },
    })
  end
end)

for i = 1, count do
  local space = sbar.add("item", "rift" .. i, {
    position = "center",
    icon = {
      color = colors.dim,
      string = icons.space,
      padding_left = 4,
      padding_right = 4,
    },
    label = {
      drawing = false,
    },
  })

  space:subscribe("mouse.clicked", function()
    mouse_click(i)
  end)
  spaces[i] = space
end
