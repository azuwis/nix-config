{ config, lib, pkgs, ... }:

if builtins.hasAttr "hm" lib then

{
  home.packages = [ pkgs.kitty ];
  xdg.configFile."kitty/kitty.conf".text = ''
    font_family JetBrains Mono
    font_size 15.0
    symbol_map U+E5FA-U+E62B,U+E700-U+E7C5,U+F000-U+F2E0,U+E200-U+E2A9,U+F500-U+FD46,U+E300-U+E3EB,U+F400-U+F4A8,U+2665,U+26A1,U+F27C,U+E0A3,U+E0B4-U+E0C8,U+E0CA,U+E0CC-U+E0D2,U+E0D4,U+23FB-U+23FE,U+2B58,U+F300-U+F313,U+E000-U+E00D JetBrainsMono Nerd Font
    cursor_blink_interval 0
    copy_on_select yes
    hide_window_decorations yes

    # nord colorscheme
    foreground           #D8DEE9
    background           #2E3440
    selection_foreground #000000
    selection_background #FFFACD
    url_color            #0087BD
    cursor               #81A1C1
    color0  #3B4252
    color8  #4C566A
    color1  #BF616A
    color9  #BF616A
    color2  #A3BE8C
    color10 #A3BE8C
    color3  #EBCB8B
    color11 #EBCB8B
    color4  #81A1C1
    color12 #81A1C1
    color5  #B48EAD
    color13 #B48EAD
    color6  #88C0D0
    color14 #8FBCBB
    color7  #E5E9F0
    color15 #ECEFF4
  '';
}

else

{
  environment.variables = {
    TERMINFO_DIRS = "${pkgs.kitty.terminfo.outPath}/share/terminfo";
  };
}
