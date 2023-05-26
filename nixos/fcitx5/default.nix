{ config, lib, pkgs, ... }:

let
  addons = with pkgs; [
    fcitx5-chinese-addons
  ];
  fcitx5 = pkgs.fcitx5-with-addons.override { inherit addons; };
in

if builtins.hasAttr "hm" lib then

{
  # home.activation.fcitx5 = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #   ${fcitx5}/bin/fcitx5-remote -r || true
  # '';
  xdg.configFile.fcitx5.source = ./config;
  wayland.windowManager.sway.config.startup = [{
    command = "${fcitx5}/bin/fcitx5";
  }];
}

else

{
  i18n.inputMethod.enabled = "fcitx5";
  i18n.inputMethod.fcitx5.addons = addons;
}
