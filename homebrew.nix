{ config, pkgs, ... }:

{
  environment.systemPath =  [ "/opt/homebrew/bin" ];
  homebrew = {
    enable = true;
    autoUpdate = true;
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
    ];
    casks = [
    ];
    masApps = {
      # Xcode = 497799835;
    };
  };
}
