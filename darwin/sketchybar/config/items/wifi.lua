local icons = require("icons")

local wifi = sbar.add("item", "wifi", {
  position = "right",
  icon = {
    string = icons.wifi.off,
    padding_right = 10,
  },
  label = {
    drawing = false,
  },
})

wifi:subscribe("wifi_change", function()
  sbar.exec("ipconfig getsummary en0", function(info)
    wifi:set({
      icon = string.find(info, "LinkStatusActive : TRUE") and icons.wifi.on or icons.wifi.off,
    })
  end)
end)
