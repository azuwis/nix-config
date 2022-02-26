{ config, lib, pkgs, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.${config.my.user} = { imports = [
    ../../common/my.nix
    ./alacritty.nix
    ./direnv.nix
    ./firefox
    ./git.nix
    ./gnupg.nix
    ./mpv.nix
    ./neovim
    ./nix-index.nix
    ./nnn
    ./packages.nix
    ./rime
    ./zsh-ssh-agent.nix
    ./zsh.nix
  ]; };
}
