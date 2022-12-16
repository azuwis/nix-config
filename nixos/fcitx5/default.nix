{ config, lib, pkgs, ... }:

if builtins.hasAttr "hm" lib then

{
  # home.activation.fcitx5 = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #   ${fcitx5}/bin/fcitx5-remote -r || true
  # '';
  xdg.configFile.fcitx5.source = ./config;
}

else

{
  i18n.inputMethod.enabled = "fcitx5";
  i18n.inputMethod.fcitx5.addons = with pkgs; [
    fcitx5-chinese-addons
  ];
}
