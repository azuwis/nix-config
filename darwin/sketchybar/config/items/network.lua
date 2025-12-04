local prev_ibytes = 0
local prev_obytes = 0

local function format(num)
  local K = 1024
  local M = K * K
  if num >= M then
    return string.format("%.2fM", num / M)
  else
    return string.format("%.0fK", num / K)
  end
end

local network = sbar.add("item", "network", {
  position = "right",
  icon = {
    drawing = false,
  },
  update_freq = 10,
})

network:subscribe({ "forced", "routine" }, function(env)
  sbar.exec("netstat -ibn -I en0", function(info)
    local ibytes, obytes = info:match("en0%s+%S+%s+%S+%s+%S+%s+%S+%s+%S+%s+(%d+)%s+%d+%s+%S+%s+(%d+)")
    if ibytes ~= nil and obytes ~= nil then
      ibytes = tonumber(ibytes, 10)
      obytes = tonumber(obytes, 10)
      if env.SENDER == "forced" then
        prev_ibytes = ibytes
        prev_obytes = obytes
      end
      local ispeed = (ibytes - prev_ibytes) / 10
      local ospeed = (obytes - prev_obytes) / 10
      prev_ibytes = ibytes
      prev_obytes = obytes
      network:set({
        label = format(ispeed) .. "↓ " .. format(ospeed) .. "↑",
      })
    end
  end)
end)
