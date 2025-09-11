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
    i18n.inputMethod.enable = true;
    i18n.inputMethod.type = "fcitx5";
    i18n.inputMethod.fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-chinese-addons
      fcitx5-fluent
    ];
    i18n.inputMethod.fcitx5.plasma6Support = true;
    i18n.inputMethod.fcitx5.waylandFrontend = lib.mkDefault true;

    i18n.inputMethod.fcitx5.settings = {
      globalOptions = {
        Behavior = {
          ActiveByDefault = "True";
        };
        "Hotkey/EnumerateForwardKeys"."0" = "Control+Shift_L";
      };
      inputMethod = {
        GroupOrder."0" = "Default";
        "Groups/0" = {
          Name = "Default";
          "Default Layout" = "us";
          DefaultIM = "keyboard-us";
        };
        "Groups/0/Items/0".Name = "shuangpin";
        "Groups/0/Items/1".Name = "keyboard-us";
      };
      addons = {
        classicui.globalSection = {
          Font = "Sans 13";
          Theme = "FluentDark-solid";
        };
        clipboard.globalSection = {
          "Number of entries" = 30;
        };
        pinyin.globalSection = {
          PinyinInPreedit = "True";
          ShuangpinProfile = "Custom";
        };
        # punctuation.globalSection = {
        #   HalfWidthPuncAfterLetterOrNumber = "False";
        # };
      };
    };

    environment.etc."xdg/fcitx5/pinyin/sp.dat".source = ./sp.dat;

    my.wayland.startup.fcitx5 = [ "fcitx5" ];
  };
}
