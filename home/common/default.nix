{ config, lib, pkgs, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.${config.my.user} = { imports = [
    ../../common/alacritty.nix
    ../../common/direnv.nix
    ../../common/firefox
    ../../common/git.nix
    ../../common/mpv.nix
    ../../common/my.nix
    ../../common/neovim
    ../../common/nix-index.nix
    ../../common/nnn
    ../../common/packages.nix
    ../../common/rime
    ../../common/zsh.nix
    ../../common/zsh-ssh-agent.nix
  ]; };
}
