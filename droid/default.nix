{ config, lib, pkgs, ... }:

{
  imports = [
    ./compat.nix
    ./sshd.nix
    ./system.nix
    ./termux.nix
  ];

  hm.imports = [
    ../common/zsh-ssh-agent.nix
    ./gnupg.nix
    ./packages.nix
  ];
}
