{ config, lib, pkgs, ... }:

let update-nix-fetchgit-vim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "update-nix-fetchgit.vim";
    version = "2022-01-25";
    src = ./update-nix-fetchgit;
  };
in

{
  programs.neovim = {
    extraPackages = [ pkgs.update-nix-fetchgit ];
    plugins = [ update-nix-fetchgit-vim ];
  };
}
