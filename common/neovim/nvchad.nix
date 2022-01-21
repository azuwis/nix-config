{ config, lib, pkgs, ... }:

let
  custom = ./nvchad;
  nvchad = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvchad";
    version = "2022-01-20";
    src = pkgs.fetchFromGitHub {
      owner = "NvChad";
      repo = "NvChad";
      rev = "8f7b19f23b17dbd9dd814299d6b52039914d21b";
      sha256 = "sha256-Q0IYNImLwLEQVhx1p3v4rBM8b/pQth04pHcYtkS8h2I=";
    };
    postPatch = ''
      ${pkgs.gnused}/bin/sed -i \
        -e 's/show_close_icon = true,/show_close_icon = false,/' \
        -e 's/show_buffer_close_icons = true,/show_buffer_close_icons = false,/' \
        lua/plugins/configs/bufferline.lua
      mkdir -p lua/custom/
      cp -r ${custom}/*.lua lua/custom/
    '';
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
}
