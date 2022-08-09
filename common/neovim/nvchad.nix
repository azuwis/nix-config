{ config, lib, pkgs, ... }:

let
  nvchad = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvchad";
    version = "unstable-2022-08-09";
    src = pkgs.fetchFromGitHub {
      owner = "NvChad";
      repo = "NvChad";
      rev = "01b17d2ad6d47008b27f38bff7fa490f56fae03f";
      sha256 = "1djxdz4pxlckri5ihqb488nq546kb8v507fdiai8l3bpb9zqvw1n";
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
