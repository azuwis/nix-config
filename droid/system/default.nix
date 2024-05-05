{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.etcBackupExtension = ".bak";
  environment.motd = "";
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  system.stateVersion = "21.11";
}
