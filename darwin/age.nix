{ config, lib, pkgs, ... }:

{
  # https://github.com/LnL7/nix-darwin/pull/381
  age.sshKeyPaths = [ "/etc/age/keys.txt" ];
}
