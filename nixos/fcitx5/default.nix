{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.fcitx5;
in
{
  options.my.fcitx5 = {
    enable = mkEnableOption "fcitx5";
  };

  config = mkIf cfg.enable {
    hm.my.fcitx5.enable = true;
    i18n.inputMethod.enable = true;
    i18n.inputMethod.type = "fcitx5";
    i18n.inputMethod.fcitx5.addons = with pkgs; [
      libsForQt5.fcitx5-chinese-addons
      fcitx5-fluent
    ];
    i18n.inputMethod.fcitx5.waylandFrontend = lib.mkDefault true;
  };
}
