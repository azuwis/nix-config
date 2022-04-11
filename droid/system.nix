{ config, lib, pkgs, ... }:

{
  environment.etcBackupExtension = ".bak";
  # auto-optimise-store gives error `cannot link ... to ...: Operation not permitted`
  nix.extraOptions = lib.mkAfter ''
    auto-optimise-store = false
  '';
  system.stateVersion = "21.11";
}
