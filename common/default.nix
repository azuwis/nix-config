{ config, lib, pkgs, ... }:

{
  imports = [
    (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" config.my.user ])
    ./my.nix
    ./system.nix
  ];

  hm.imports = [
    ./difftastic.nix
    ./direnv.nix
    ./git.nix
    ./gnupg.nix
    ./my.nix
    ./neovim
    ./nnn
    ./nix-index.nix
    ./packages.nix
    ./zsh.nix
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  hm = {
    home.stateVersion = "22.05";
  };
}
