local icons = require("icons")

local load = sbar.add("item", "load", {
  position = "right",
  icon = icons.load,
  update_freq = 60,
})

load:subscribe({ "forced", "routine" }, function()
  sbar.exec("sysctl -n vm.loadavg", function(load_info)
    local avg = tonumber(load_info:match("(%d+%.%d+)"))
    load:set({
      label = {
        highlight = avg >= 4,
        string = avg,
      },
    })
  end)
end)
