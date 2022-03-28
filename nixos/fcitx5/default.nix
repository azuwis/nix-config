{ config, lib, pkgs, ...}:

let
  fcitx5 = pkgs.fcitx5-with-addons.override {
    fcitx5-configtool = null;
    addons = with pkgs; [
      fcitx5-chinese-addons
    ];
  };
in

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
  i18n.inputMethod.package = lib.mkForce fcitx5;
  systemd.user.services.fcitx5-daemon.script = lib.mkForce "${fcitx5}/bin/fcitx5";
}
