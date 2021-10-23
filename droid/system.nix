{ pkgs, config, ... }:

{
  environment.etcBackupExtension = ".bak";
  system.stateVersion = "21.05";
  user.shell = "${pkgs.zsh}/bin/zsh";
}
