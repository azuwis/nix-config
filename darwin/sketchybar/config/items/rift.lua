local colors = require("colors")
local icons = require("icons")
local rift = require("rift")
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

-- Workspace indexes are global across native spaces, so the k-th space owns
-- k * #spaces + 1 .. k * #spaces + #spaces, fold them back into 1..#spaces.
client:subscribe({ "workspace_changed" }, function(env)
  if #spaces == 0 then
    return
  end
  local index = env.DATA.workspace_id.idx % #spaces
  if index == 0 then
    index = #spaces
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
  if #spaces == 0 then
    return
  end
  local index = env.DATA.workspace_id.idx % #spaces
  if index == 0 then
    index = #spaces
  end
  local is_empty = next(env.DATA.windows) == nil
  spaces[index]:set({
    icon = {
      color = is_empty and colors.dim or colors.default,
    },
  })
end)

-- Rift runs `sketchybar --reload` from run_on_start before it has any native
-- space state, so the first get_workspaces can come back empty.
local function setup()
  local resp = client:send_request([[{"get_workspaces":{"space_id":null}}]])
  local data = (resp and resp.data) or {}
  if #data == 0 then
    print("rift.lua: no workspaces yet, retrying")
    sbar.delay(0.1, setup)
    return
  end

  for index, ws in ipairs(data) do
    local space = sbar.add("item", "rift" .. index, {
      position = "center",
      icon = {
        color = ws.window_count == 0 and colors.dim or colors.default,
        highlight = ws.is_active,
        string = icons.space,
        padding_left = 4,
        padding_right = 4,
      },
      label = {
        drawing = false,
      },
    })

    space:subscribe("mouse.clicked", function()
      mouse_click(index)
    end)
    spaces[index] = space

    if ws.is_active then
      current = index
    end
  end
end

sbar.delay(0.1, setup)
