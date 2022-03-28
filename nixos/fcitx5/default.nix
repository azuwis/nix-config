{ config, lib, pkgs, ...}:

if builtins.hasAttr "hm" lib then

{
  xdg.configFile.fcitx5.source = ./config;
}

else

{
  i18n.inputMethod.enabled = "fcitx5";
  i18n.inputMethod.fcitx5.addons = with pkgs; [
    fcitx5-chinese-addons
  ];
}
