{ config, lib, pkgs, ... }:

let
  update-nix-fetchgit-vim = pkgs.vimUtils.buildVimPlugin {
    pname = "update-nix-fetchgit.vim";
    version = "2022-01-25";
    src = lib.fileset.toSource {
      root = ./.;
      fileset = ./ftplugin;
    };
  };
in

{
  config = lib.mkIf config.my.neovim.enable {
    programs.neovim = {
      extraPackages = [ pkgs.update-nix-fetchgit ];
      plugins = [ update-nix-fetchgit-vim ];
    };
  };
}
