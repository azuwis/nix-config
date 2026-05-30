{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.programs.fcitx5;
in
{
  options.programs.fcitx5 = {
    enable = mkEnableOption "fcitx5";
  };

  config = mkIf cfg.enable {
    i18n.inputMethod.enable = true;
    i18n.inputMethod.type = "fcitx5";
    i18n.inputMethod.fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-chinese-addons
      fcitx5-fluent
    ];
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
        punctuation.globalSection = {
          HalfWidthPuncAfterLetterOrNumber = "False";
        };
      };
    };

    environment.etc."xdg/fcitx5/pinyin/sp.dat".source = ./sp.dat;

    environment.sessionVariables = {
      # fcitx5 writes ~/.config/fcitx5 on exit, which would overwrite the
      # declarative config from /etc/xdg/fcitx5/. Redirecting FCITX_CONFIG_HOME
      # to a read-only empty store path prevents this.
      #
      # Prefer this over i18n.inputMethod.fcitx5.ignoreUserConfig, which sets SKIP_FCITX_USER_PATH=1
      # and blocks both config and data — user dictionaries would be lost.
      FCITX_CONFIG_HOME = "${pkgs.emptyDirectory}";
    };

    programs.wayland.startup.fcitx5 = [ "fcitx5" ];
  };
}
