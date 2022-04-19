{ config, lib, pkgs, ... }:

if builtins.hasAttr "hm" lib then

{
  xsession.pointerCursor = {
    name = "Vanilla-DMZ-AA";
    package = pkgs.vanilla-dmz;
  };
}

else

{
  fonts = {
    fonts = with pkgs; [
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
}
