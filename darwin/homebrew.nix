{ config, lib, pkgs, ... }:

{
  environment.systemPath = [ "/opt/homebrew/bin" ];
  environment.variables = { HOMEBREW_NO_ANALYTICS = "1"; };
  homebrew = {
    enable = true;
    # autoUpdate = true;
    cleanup = "zap";
    global = {
      brewfile = true;
      noLock = true;
    };
    brewPrefix = "/opt/homebrew/bin";
    taps = [
      "homebrew/core"
      "homebrew/cask"
      # "homebrew/homebrew-services"
    ];
    brews = [
      "blueutil"
      "mas"
      "tofrodos"
    ];
    casks = [
      "android-file-transfer"
      "android-platform-tools"
      "google-chrome"
      "microsoft-office"
      "musescore"
      "qbittorrent"
      "reaper"
    ];
    masApps = {
      "Microsoft Remote Desktop" = 1295203466;
      WeChat = 836500024;
      # Xcode = 497799835;
    };
    extraConfig = ''
      cask "battle-net", args: { language: "zh-CN" }
    '';
  };
}
