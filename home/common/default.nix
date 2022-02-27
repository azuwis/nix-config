{ config, lib, pkgs, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.${config.my.user} = { imports = [
    ../../common/my.nix
    ./direnv.nix
    ./git.nix
    ./gnupg.nix
    ./neovim
    ./nix-index.nix
    ./nnn
    ./packages.nix
    ./zsh-ssh-agent.nix
    ./zsh.nix
  ]; };
}
