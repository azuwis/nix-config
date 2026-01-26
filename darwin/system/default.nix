{
  config,
  lib,
  pkgs,
  ...
}:

{
  # https://github.com/nix-darwin/nix-darwin/pull/1341
  system.primaryUser = config.my.user;
  users.users.${config.my.user}.home = "/Users/${config.my.user}";
  # Disable user profiles, they're for `home-manager` `nix-env` `nix profile install`, not used here
  environment.profiles = lib.mkForce [ "/run/current-system/sw" ];
  environment.variables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };
  documentation.doc.enable = false;
  documentation.info.enable = false;
  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];
  nix.settings = {
    allowed-users = [ config.my.user ];
    extra-platforms = [ "x86_64-darwin" ];
    # `replaceVarsWith { isExecutable = true; ... }` fail with sandbox enabled, use `dontPatchShebangs = true;` to workaround
    # https://github.com/NixOS/nixpkgs/issues/343576
    sandbox = "relaxed";
  };
  # nix profile diff-closures --profile /nix/var/nix/profiles/system
  # show upgrade diff
  # ${pkgs.nix}/bin/nix store --experimental-features nix-command diff-closures /run/current-system "$systemConfig"
  system.activationScripts.postActivation.text = ''
    # disable spotlight
    launchctl unload -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist >/dev/null 2>&1 || true
    # disable fseventsd on /nix volume
    mkdir -p /nix/.fseventsd
    test -e /nix/.fseventsd/no_log || touch /nix/.fseventsd/no_log
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
    swapLeftCommandAndLeftAlt = true;
  };
  system.stateVersion = 4;
  # Reduse closure size, use `nix run nix-darwin#darwin-uninstaller` if needed
  system.tools.darwin-uninstaller.enable = false;
}
