{ config, lib, pkgs, ... }:

{
  imports = [
    (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" config.my.user ])
    ./my.nix
    ./system.nix
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
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
  hm.home.stateVersion = "22.05";
}
