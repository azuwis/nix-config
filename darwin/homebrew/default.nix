{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPath = [ "/opt/homebrew/bin" ];
  environment.variables = {
    HOMEBREW_NO_ANALYTICS = "1";
  };
  homebrew = {
    enable = true;
    onActivation = {
      # autoUpdate = true;
      cleanup = "zap";
    };
    global = {
      brewfile = true;
    };
    taps = [
      "homebrew/core"
      "homebrew/cask"
      # "homebrew/homebrew-services"
    ];
    brews = [ "mas" ];
    casks = [
      "google-chrome"
      "microsoft-office"
      "musescore"
      "native-access"
      "obs"
      "olive"
      "reaper"
    ];
    masApps = {
      "Microsoft Remote Desktop" = 1295203466;
      DingTalk = 1435447041;
      WeChat = 836500024;
      # Xcode = 497799835;
    };
    extraConfig = ''
      # cask "battle-net", args: { language: "zh-CN" }
    '';
  };
}
