{ config, lib, pkgs, ... }:

{
  programs.zsh.initExtra = ''
  start-sshd() {
    ~/.nix-profile/bin/sshd -f ~/.ssh/sshd_config
  }
  '';
}
