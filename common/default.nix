{ config, lib, pkgs, ... }:

{
  imports = [
    ./my.nix
    ./system.nix
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${config.my.user} = { imports = [
        ./difftastic.nix
        ./direnv.nix
        ./git.nix
        ./gnupg.nix
        ./mpv.nix
        ./my.nix
        ./neovim
        ./nnn
        ./nix-index.nix
        ./packages.nix
        ./zsh.nix
      ]; };
    }
  ];
}
