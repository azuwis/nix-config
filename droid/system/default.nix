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
    flake-registry =
  '';
  system.stateVersion = "21.11";
}
