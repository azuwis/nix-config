{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.etcBackupExtension = ".bak";
  # https://github.com/termux/termux-packages/issues/1174
  environment.etc."resolv.conf".enable = false;
  environment.motd = "";
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  system.stateVersion = "21.11";
}
