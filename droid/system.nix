{ config, lib, pkgs, ... }:

{
  environment.etcBackupExtension = ".bak";
  # auto-optimise-store gives error `cannot link ... to ...: Operation not permitted`
  # nix.settings.auto-optimise-store = false;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  system.stateVersion = "21.11";
}
