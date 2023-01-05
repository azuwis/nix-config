{ config, lib, pkgs, ... }:

let
  nvchad = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvchad";
    version = "unstable-2022-12-24";
    src = pkgs.fetchFromGitHub {
      owner = "NvChad";
      repo = "NvChad";
      rev = "e6a230129ac16f23120424f4cee35fedcb6bf774";
      sha256 = "1kamjv7gnc7jbhi10cnpgpa2m3xw8a9j8yvgadcqfcw9kigiw5v4";
    };
    meta.homepage = "https://github.com/NvChad/NvChad/";
  };
in

{
  programs.neovim = {
    # plugins = [ nvchad pkgs.vimPlugins.telescope-fzf-native-nvim ];
    plugins = [ nvchad ];
  };
  xdg.configFile."nvim/init.lua".text = ''
    vim.cmd [[source ${nvchad}/init.lua]]
  '';
  xdg.configFile."nvim/lua/custom".source = ./nvchad;
  xdg.configFile."nvim/lua/telescope".source = ./telescope;
}
