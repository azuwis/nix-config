{ config, lib, pkgs, ... }:

let
  nvchad = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvchad";
    version = "unstable-2022-05-27";
    src = pkgs.fetchFromGitHub {
      owner = "NvChad";
      repo = "NvChad";
      rev = "f8b5571466173f6518ab22351bacda186fd23b2e";
      sha256 = "1v2c27vp4jzzy3hwc4sw0a4mjl39nmn7cqg8vk5jva6h8x836p7c";
    };
    # nvim-lsp-installer does not work well on NixOS, e.g. It checks nodejs when yamlls exe already exists
    postPatch = ''
      sed -i \
        -e '/after = "nvim-lsp-installer",/d' \
        lua/plugins/init.lua
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
  xdg.configFile."nvim/lua/custom".source = ./nvchad;
}
