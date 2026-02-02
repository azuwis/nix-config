{
  config,
  lib,
  pkgs,
  ...
}:

let
  inputs = import ../../inputs { };
in

{
  imports = [ (inputs.nix-homebrew.outPath + "/modules") ];

  registry.entries = [
    "homebrew-cask"
    "nix-homebrew"
  ];

  nix-homebrew = {
    inherit (config.my) user;
    enable = true;
    # Do not add /opt/homebrew/bin in PATH, not used for now
    # https://github.com/zhaofengli/nix-homebrew/blob/159f21ae77da757bbaeb98c0b16ff2e7b2738350/modules/default.nix#L459
    enableZshIntegration = false;
    extraEnv = {
      HOMEBREW_NO_ANALYTICS = "1";
    };
    mutableTaps = false;
    # https://github.com/zhaofengli/nix-homebrew/blob/6a8ab60bfd66154feeaa1021fc3b32684814a62a/flake.nix
    package =
      let
        flakeLock = builtins.fromJSON (builtins.readFile (inputs.nix-homebrew.outPath + "/flake.lock"));
        brewVersion = flakeLock.nodes.brew-src.original.ref;
        locked = flakeLock.nodes.brew-src.locked;
      in
      {
        name = "brew-${brewVersion}";
        version = brewVersion;
        outPath = builtins.fetchTarball {
          url = "https://github.com/${locked.owner}/${locked.repo}/archive/${locked.rev}.tar.gz";
          sha256 = locked.narHash;
        };
      };
    # Add `homebrew-core = github "Homebrew/homebrew-core" { };` to inputs/inputs.nix, run `os update homebrew-core`
    taps = {
      # "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
  };

  homebrew = {
    enable = true;
    onActivation = {
      # When `nix-homebrew.mutableTaps` is false, autoUpdate will have not
      # effect because `HOMEBREW_NO_AUTO_UPDATE=1` set in `brew` wrapper
      # https://github.com/zhaofengli/nix-homebrew/blob/main/modules/default.nix#L126-L128
      # autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    # Set according to nix-homebrew.taps, or `Refusing to untap ...`
    taps = [
      # "homebrew/core"
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
