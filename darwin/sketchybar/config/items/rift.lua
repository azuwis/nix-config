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
    string.format([[{"execute_command":{"command":"{\"Reactor\":{\"switch_to_workspace\":%d}}","args":[]}}]], index - 1)
  )
  if not resp then
    print("rift.lua: " .. tostring(send_err))
  end
end

local function refresh()
  local resp = client:send_request([[{"get_workspaces":{"space_id":null}}]])
  if not resp or not resp.data then
    return
  end
  for _, ws in ipairs(resp.data) do
    local index = ws.index + 1
    if spaces[index] then
      spaces[index]:set({
        icon = {
          highlight = ws.is_active,
          color = ws.window_count == 0 and colors.dim or colors.default,
        },
      })
      if ws.is_active then
        current = index
      end
    end
  end
end

-- Workspace indexes are global across native spaces (the k-th space owns
-- k * count + 1 .. k * count + count), fold them back into 1..count.
client:subscribe({ "workspace_changed" }, function(env)
  local index = env.DATA.workspace_id.idx % count
  if index == 0 then
    index = count
  end
  if index == current then
    return
  end
  if spaces[current] then
    spaces[current]:set({ icon = { highlight = false } })
  end
  spaces[index]:set({ icon = { highlight = true } })
  current = index
end)

client:subscribe({ "windows_changed" }, function(env)
  local is_empty = next(env.DATA.windows) == nil
  local index = env.DATA.workspace_id.idx % count
  if index == 0 then
    index = count
  end
  spaces[index]:set({
    icon = {
      color = is_empty and colors.dim or colors.default,
    },
  })
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

refresh()
