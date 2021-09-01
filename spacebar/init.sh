spacebar -m config display main
spacebar -m config height 24
spacebar -m config dnd off
spacebar -m config padding_left 14
spacebar -m config padding_right 14
spacebar -m config spacing_left 16
spacebar -m config spacing_right 14
spacebar -m config text_font "JetBrains Mono:Regular:13.0"
spacebar -m config icon_font "JetBrains Mono:Regular:13.0"
spacebar -m config background_color 0xff2e3440
spacebar -m config foreground_color 0xbbd8dee9
spacebar -m config space_icon_color 0xffebcb8b
spacebar -m config space_icon_color_secondary 0xff78c4d4
spacebar -m config space_icon_color_tertiary 0xfffff9b0
spacebar -m config power_icon_color 0xbbd8dee9
spacebar -m config battery_icon_color 0xbbd8dee9
spacebar -m config clock_icon_color 0xbbd8dee9
spacebar -m config power_icon_strip 􀛨 􀢋
spacebar -m config space_icon_strip 1° 2° 3° 4° 5° 6° 7° 8° 9° 10°
spacebar -m config clock_icon " "
spacebar -m config clock_format "%a %m-%d %H:%M"
spacebar -m config right_shell on
spacebar -m config right_shell_icon " "
spacebar -m config right_shell_command /etc/spacebar/right-shell.sh

cache="$HOME/.cache/spacebar"
mkdir -p "$cache"
if ! mount | grep -qF "$cache"
then
  disk=$(hdiutil attach -nobrowse -nomount ram://1024)
  disk="${disk%% *}"
  newfs_hfs -v spacebar $disk
  mount -t hfs -o nobrowse $disk "$cache"
fi
