{ config, lib, pkgs, ... }:

{
  # darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/configuration.nix
  # sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist
  environment.darwinConfig = "$HOME/.config/nixpkgs/configuration.nix";
  environment.systemPackages = with pkgs; [ sf-symbols-app ];
  environment.variables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };
  fonts.enableFontDir = true;
  fonts.fonts = with pkgs; [ jetbrains-mono jetbrains-mono-nerdfont sf-symbols ];
  # nix.extraOptions = ''
  #   extra-platforms = x86_64-darwin aarch64-darwin
  # '';
  # nix.extraOptions = ''
  #   experimental-features = flakes nix-command
  # '';
  # nix.package = pkgs.nixUnstable;
  launchd.daemons.activate-system.script = lib.mkOrder 0 ''
    wait4path /nix/store
  '';
  nixpkgs.overlays = import ./overlays.nix;
  programs.zsh.enable = true;
  services.nix-daemon.enable = true;
  system.activationScripts.postActivation.text = ''
    ${pkgs.nixUnstable}/bin/nix store --experimental-features nix-command diff-closures /run/current-system "$systemConfig"
  '';
  system.defaults = {
    NSGlobalDomain = {
      AppleMeasurementUnits = "Centimeters";
      AppleMetricUnits = 1;
      AppleShowAllExtensions = true;
      AppleTemperatureUnit = "Celsius";
      InitialKeyRepeat = 20;
      KeyRepeat = 2;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSDisableAutomaticTermination = true;
      NSDocumentSaveNewDocumentsToCloud = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      NSTableViewDefaultSizeMode = 2;
      NSWindowResizeTime = "0.0001";
      PMPrintingExpandedStateForPrint = true;
      PMPrintingExpandedStateForPrint2 = true;
    };
    LaunchServices.LSQuarantine = false;
    dock = {
      autohide = true;
      expose-animation-duration = "0";
      mineffect = "scale";
      minimize-to-application = true;
      mru-spaces = false;
      orientation = "left";
      show-recents = false;
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
