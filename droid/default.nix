{ config, lib, pkgs, ... }:

{
  imports = [
    ./compat.nix
    ./sshd.nix
    ./system.nix
    ./termux.nix
    {
      home-manager.users.${config.my.user} = { imports = [
        ../common/zsh-ssh-agent.nix
        ./gnupg.nix
        ./packages.nix
      ]; };
    }
  ];
}
