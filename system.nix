{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
  ];
  environment.variables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };
  fonts.enableFontDir = true;
  fonts.fonts = [ pkgs.jetbrains-mono ];
  # nix.extraOptions = ''
  #   experimental-features = flakes nix-command
  # '';
  # nix.package = pkgs.nixUnstable;
  programs.zsh.enable = true;
  services.nix-daemon.enable = true;
  system.activationScripts.postActivation.text = ''
    ${pkgs.nixUnstable}/bin/nix store --experimental-features nix-command diff-closures /run/current-system "$systemConfig"
  '';
  system.defaults = {
    NSGlobalDomain = {
      InitialKeyRepeat = 20;
      KeyRepeat = 2;
    };
    dock = {
      autohide = true;
      expose-animation-duration = "0";
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
