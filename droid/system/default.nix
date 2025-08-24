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
  nix.package = pkgs.nix;
  system.stateVersion = "21.11";
  time.timeZone = "Asia/Shanghai";
}
