{ config, lib, pkgs, ... }:

let
  nvchad = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvchad";
    version = "unstable-2022-02-17";
    src = pkgs.fetchFromGitHub {
      owner = "NvChad";
      repo = "NvChad";
      rev = "9ca0af1a24601990fe7d15cb2d242ebaf768db9e";
      sha256 = "137vlvhk8ia8b1vh96m5mbb180j7az335cadxbccsjc126ddx4kr";
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
