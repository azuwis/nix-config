{ config, pkgs, ... }:

{
  system.defaults.NSGlobalDomain = {
    InitialKeyRepeat = 20;
    KeyRepeat = 2;
  };
  system.defaults.dock.autohide = true;
  system.defaults.trackpad = {
    Clicking = true;
    Dragging = true;
    TrackpadThreeFingerDrag = true;
  };
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };
}
