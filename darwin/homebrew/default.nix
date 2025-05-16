{
  config,
  lib,
  pkgs,
  ...
}:

let
  inputs = import ../../inputs;
in

{
  imports = [ (inputs.nix-homebrew.outPath + "/modules") ];

  nix-homebrew = {
    inherit (config.my) user;
    enable = true;
    extraEnv = {
      HOMEBREW_NO_ANALYTICS = "1";
    };
    mutableTaps = false;
    package = inputs.brew-src // {
      name = "brew-${inputs.brew-src.version}";
    };
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
  };

  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      upgrade = true;
    };
    global = {
      brewfile = true;
    };
    # Set according to nix-homebrew.tags, or `Refusing to untap ...`
    taps = [
      "homebrew/core"
      "homebrew/cask"
    ];
    # brews = [ "mas" ];
    casks = [
      "google-chrome"
      "microsoft-office"
      "musescore"
      "native-access"
      "obs"
      "olive"
      "reaper"
    ];
    # mas does not work (`mas list` hang), maybe related to spotlight index
    # https://github.com/mas-cli/mas/issues/805
    # masApps = {
    #   "Microsoft Remote Desktop" = 1295203466;
    #   DingTalk = 1435447041;
    #   WeChat = 836500024;
    #   # Xcode = 497799835;
    # };
    extraConfig = ''
      # cask "battle-net", args: { language: "zh-CN" }
    '';
  };
}
