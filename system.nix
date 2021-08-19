{ config, lib, pkgs, ... }:

{
  # darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/configuration.nix
  environment.darwinConfig = "$HOME/.config/nixpkgs/configuration.nix";
  environment.systemPackages = with pkgs; [
  ];
  environment.variables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };
  fonts.enableFontDir = true;
  fonts.fonts = with pkgs; [
    jetbrains-mono
    sf-symbols
  ];
  # nix.extraOptions = ''
  #   experimental-features = flakes nix-command
  # '';
  # nix.package = pkgs.nixUnstable;
  nixpkgs.overlays = import ./overlays.nix;
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
