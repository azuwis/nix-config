{ config, lib, pkgs, ... }:

{
  programs.zsh.envExtra = ''
  . "/data/data/com.termux.nix/files/home/.nix-profile/etc/profile.d/nix-on-droid-session-init.sh"
  '';
  programs.zsh.initExtra = ''
  start-sshd() {
    ~/.nix-profile/bin/sshd -f ~/.ssh/sshd_config
  }
  '';
}
