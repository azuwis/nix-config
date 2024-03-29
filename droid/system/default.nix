{ config, lib, pkgs, ... }:

{
  environment.etcBackupExtension = ".bak";
  # https://github.com/termux/termux-packages/issues/1174
  environment.etc."resolv.conf".enable = false;
  environment.motd = "";
  # auto-optimise-store gives error `cannot link ... to ...: Operation not permitted`
  # nix.settings.auto-optimise-store = false;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  system.stateVersion = "21.11";
}
