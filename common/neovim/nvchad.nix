{ config, lib, pkgs, ... }:

let
  custom = ./nvchad;
  nvchad = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvchad";
    version = "2022-01-11";
    src = pkgs.fetchFromGitHub {
      owner = "NvChad";
      repo = "NvChad";
      rev = "b1338beb0f775deb55c91a88a09e6738e73e5f97";
      sha256 = "sha256-tLCIhV2uwJrwh4feIahfk6xuDhZPGQWhQD1LjufwcBM=";
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
