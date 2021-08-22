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
    brews = [ ];
    casks = [ ];
    masApps = {
      # Xcode = 497799835;
    };
  };
}
