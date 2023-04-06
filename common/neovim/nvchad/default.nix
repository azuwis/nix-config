{ config, lib, pkgs, ... }:

let
  nvchad = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvchad";
    version = "unstable-2023-04-03";
    src = pkgs.fetchFromGitHub {
      owner = "NvChad";
      repo = "NvChad";
      rev = "4d455974688392abf0d8e420bc5099d1e0bd3204";
      sha256 = "01j25mmx3nr8b4876z0rrz202zx50lnbyyz7h2s1qd2wq48zhyax";
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
  xdg.configFile."nvim/lua".source = ./lua;
}
