local input = sbar.add("item", "input", {
  position = "right",
  icon = {
    drawing = false,
  },
})

sbar.add("event", "input_change", "AppleSelectedInputSourcesChangedNotification")

input:subscribe({ "forced", "input_change" }, function()
  sbar.exec("defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources", function(info)
    input:set({
      label = string.find(info, " = ABC;") and "ABC" or "",
    })
  end)
end)
