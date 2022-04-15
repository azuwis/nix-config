{ config, lib, pkgs, ... }:

{
  programs.mpv = {
    bindings.f = "run yabai -m window --toggle native-fullscreen";
  };
  xdg.configFile."mpv/fonts.conf".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE fontconfig SYSTEM "../fonts.dtd">
    <fontconfig>
      <dir>/System/Library/Fonts</dir>
      <!-- <dir>/Library/Fonts</dir> -->
      <!-- <dir>~/Library/Fonts</dir> -->

      <!-- Default fonts for sans, serif, monospace -->
      <alias>
        <family>sans-serif</family>
          <prefer>
            <family>PingFang SC</family>
          </prefer>
      </alias>
      <alias>
        <family>serif</family>
          <prefer>
            <family>Songti SC</family>
          </prefer>
      </alias>
      <alias>
        <family>monospace</family>
          <prefer>
            <family>Menlo</family>
            <family>PingFang SC</family>
          </prefer>
      </alias>
    </fontconfig>
  '';
}
