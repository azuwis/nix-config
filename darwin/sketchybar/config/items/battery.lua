local icons = require("icons")

local battery = sbar.add("item", "battery", {
  position = "right",
  update_freq = 120,
})

local function battery_update()
  sbar.exec("pmset -g batt", function(batt_info)
    local icon = icons.battery.unknown
    local highlight = false

    local found, _, charge = batt_info:find("(%d+)%%")
    if found then
      charge = tonumber(charge)
    else
      highlight = true
    end

    if string.find(batt_info, "AC Power") then
      icon = icons.battery.charging
    elseif found then
      if charge <= 30 then
        icon = icons.battery.low
        highlight = true
      elseif charge <= 70 then
        icon = icons.battery.medium
      else
        icon = icons.battery.high
      end
    end

    battery:set({
      icon = {
        string = icon,
        highlight = highlight,
      },
      label = {
        string = charge .. "%",
        highlight = highlight,
      },
    })
  end)
end

battery:subscribe({ "routine", "power_source_change", "system_woke" }, battery_update)
