{
  config,
  lib,
  pkgs,
  ...
}:

{
  android-integration.am.enable = true;
  environment.etcBackupExtension = ".bak";
  environment.motd = "";
  # Need to keep sync with common/system/default.nix, since nix-on-droid does
  # not support nix.settings
  nix.extraOptions = ''
    accept-flake-config = false
    experimental-features = nix-command flakes
    flake-registry =
    keep-outputs = true
    log-lines = 25
    tarball-ttl = 43200
  '';
  nix.package = pkgs.nix;
  system.stateVersion = "21.11";
  time.timeZone = "Asia/Shanghai";
}
