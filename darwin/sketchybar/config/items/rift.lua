local colors = require("colors")
local icons = require("icons")
local rift = require("rift")
local count = 8
local spaces = {}

local client, err = rift.connect()
if not client then
  error(err)
end

local function mouse_click(index)
  client:send_request(
    string.format([[{"execute_command":{"command":"{\"Reactor\":{\"switch_to_workspace\":%d}}","args":[]}}]], index)
  )
end

client:subscribe({ "workspace_changed" }, function(env)
  for index, space in ipairs(spaces) do
    space:set({
      icon = { highlight = index == env.DATA.workspace_id.idx - 1 },
    })
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
