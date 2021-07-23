{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # vim
  ];
  programs.zsh.enable = true;
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;
  system.defaults = {
    NSGlobalDomain = {
      InitialKeyRepeat = 20;
      KeyRepeat = 2;
    };
    dock = {
      autohide = true;
      mru-spaces = false;
      minimize-to-application = true;
    };
    finder = {
      AppleShowAllExtensions = true;
      _FXShowPosixPathInTitle = true;
      FXEnableExtensionChangeWarning = false;
    };
    screencapture.location = "/tmp";
    trackpad = {
      Clicking = true;
      Dragging = true;
      # TrackpadThreeFingerDrag = true;
    };
  };
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };
  system.stateVersion = 4;
  time.timeZone = "Asia/Shanghai";
}
