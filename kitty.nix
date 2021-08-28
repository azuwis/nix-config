{ config, lib, pkgs, ... }:

if builtins.hasAttr "hm" lib then

{
  home.packages = [ pkgs.kitty ];
  home.file.".config/kitty/kitty.conf".text = ''
    font_family JetBrains Mono
    font_size 15.0
    cursor_blink_interval 0
    copy_on_select yes
    hide_window_decorations yes
  '';
}

else

{
  environment.variables = {
    TERMINFO_DIRS = "${pkgs.kitty.terminfo.outPath}/share/terminfo";
  };
}
