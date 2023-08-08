{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.theme;

in
{
  options.my.theme = {
    enable = mkEnableOption (mdDoc "theme");
  };

  config = mkIf cfg.enable {
    hm.my.theme.enable = true;

    fonts = {
      packages = with pkgs; [
        fira
        jetbrains-mono-nerdfont
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        poly
      ];
      fontconfig.defaultFonts = {
        sansSerif = [
          "Fira Sans"
          "Noto Sans CJK SC"
        ];
        serif = [
          "Poly"
          "Noto Serif CJK SC"
        ];
        monospace = [
          "JetBrainsMono Nerd Font"
          "Noto Sans Mono CJK SC"
        ];
      };
    };

    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita";
    };

  };
}
