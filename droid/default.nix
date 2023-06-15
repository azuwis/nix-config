{ config, lib, pkgs, ... }:

{
  imports = [
    ./compat.nix
    ./sshd.nix
    ./system.nix
    ./termux.nix
  ];

  hm.imports = [
    ./gnupg.nix
    ./packages.nix
  ];

  hm.my.zsh-ssh-agent.enable = true;
}
