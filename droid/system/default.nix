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
  system.stateVersion = "21.11";
}
