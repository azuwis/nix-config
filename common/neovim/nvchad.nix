{ config, lib, pkgs, ... }:

let
  nvchad = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvchad";
    version = "unstable-2022-05-30";
    src = pkgs.fetchFromGitHub {
      owner = "NvChad";
      repo = "NvChad";
      rev = "59de298d8fc05b4ee2633cd2dfe9d517cf6f6d68";
      sha256 = "020a1x6m6ng0zi0694bv7pnzbnphrw1lms3jshr28kdrw3nfd4ba";
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
