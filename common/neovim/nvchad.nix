{ config, lib, pkgs, ... }:

let
  nvchad = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvchad";
    version = "unstable-2022-06-21";
    src = pkgs.fetchFromGitHub {
      owner = "NvChad";
      repo = "NvChad";
      rev = "e57a3b5de952e58e2dd13f02a4a6ae26449d1040";
      sha256 = "0wvqhlqjkd5xjhrva27bw158by5jnid30ivrfp2bhdw2ci0lvn3h";
    };
    meta.homepage = "https://github.com/NvChad/NvChad/";
  };
in

{
  programs.neovim = {
    extraConfig = ''
      source ${nvchad}/init.lua
    '';
    plugins = [ nvchad ];
  };
  xdg.configFile."nvim/lua/custom".source = ./nvchad;
}
