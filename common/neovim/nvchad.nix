{ config, lib, pkgs, ... }:

let
  nvchad = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvchad";
    version = "unstable-2022-05-15";
    src = pkgs.fetchFromGitHub {
      owner = "NvChad";
      repo = "NvChad";
      rev = "ec62a5cee85f841089ed3e8528dc0cc33a060ca6";
      sha256 = "1f6kfrpvxsl84vcvzi8dcvdpql9lw1i8nfcvdbi66v2jrad00bqw";
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
