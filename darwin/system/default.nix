{
  config,
  lib,
  pkgs,
  ...
}:

{
  users.users.${config.my.user}.home = "/Users/${config.my.user}";
  environment.variables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };
  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [ jetbrains-mono-nerdfont ];
  nix.settings.allowed-users = [ config.my.user ];
  nix.extraOptions = ''
    extra-platforms = x86_64-darwin
  '';
  launchd.daemons.activate-system.script = lib.mkOrder 0 ''
    wait4path /nix/store
  '';
  services.nix-daemon.enable = true;
  # nix profile diff-closures --profile /nix/var/nix/profiles/system
  system.activationScripts.postActivation.text = ''
    # disable spotlight
    launchctl unload -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist >/dev/null 2>&1 || true
    # disable fseventsd on /nix volume
    mkdir -p /nix/.fseventsd
    test -e /nix/.fseventsd/no_log || touch /nix/.fseventsd/no_log
    # show upgrade diff
    ${pkgs.nix}/bin/nix store --experimental-features nix-command diff-closures /run/current-system "$systemConfig"
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
      NSWindowResizeTime = 1.0e-4;
      PMPrintingExpandedStateForPrint = true;
      PMPrintingExpandedStateForPrint2 = true;
    };
    LaunchServices.LSQuarantine = false;
    dock = {
      autohide = true;
      expose-animation-duration = 0.0;
      mineffect = "scale";
      minimize-to-application = true;
      mru-spaces = false;
      orientation = "left";
      show-recents = false;
      wvous-br-corner = 1; # Disabled
    };
    finder = {
      AppleShowAllExtensions = true;
      FXDefaultSearchScope = "SCcf";
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";
      ShowPathbar = true;
    };
    screencapture = {
      disable-shadow = true;
      location = "/tmp";
    };
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
}
