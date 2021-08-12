{ config, pkgs, ... }:

{
  home-manager.users."${config.my.user}" = {
    home.packages = [ pkgs.alacritty ];
    home.file.".config/alacritty/alacritty.yml".text = ''
      font:
        normal:
          family: JetBrains Mono
        size: 15.0
      window:
        decorations: buttonless
    '';
  };
}
