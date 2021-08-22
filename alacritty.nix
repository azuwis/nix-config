{ config, lib, pkgs, ... }:

{
  home.packages = [ pkgs.alacritty ];
  home.file.".config/alacritty/alacritty.yml".text = ''
    font:
      normal:
        family: JetBrains Mono
      size: 15.0
    window:
      decorations: buttonless
      dimensions:
        columns: 106
        lines: 29
      position:
        x: 480
        y: 340
  '';
}
