{ config, lib, pkgs, ... }:

let
  nvchad = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvchad";
    version = "unstable-2022-10-07";
    src = pkgs.fetchFromGitHub {
      owner = "NvChad";
      repo = "NvChad";
      rev = "dc669313c1e3e4348c65d622734e57d7459b6f83";
      sha256 = "0fmrhqh4r49whl1wk5fxyw5gscyg23h4hzrh9wra1lxjwbcfdyq0";
    };
    meta.homepage = "https://github.com/NvChad/NvChad/";
  };
in

{
  programs.neovim = {
    plugins = [ nvchad ];
  };
  xdg.configFile."nvim/init.lua".text = ''
    vim.cmd [[source ${nvchad}/init.lua]]
  '';
  xdg.configFile."nvim/lua/custom".source = ./nvchad;
}
