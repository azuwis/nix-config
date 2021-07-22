{ config, pkgs, ... }:

{
  environment.systemPath =  [ "/opt/homebrew/bin" ];
  homebrew = {
    enable = true;
    cleanup = "zap";
    brewPrefix = "/opt/homebrew/bin";
    taps = [
      "homebrew/cask"
      "homebrew/homebrew-services"
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
