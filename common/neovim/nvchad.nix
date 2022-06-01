{ config, lib, pkgs, ... }:

let
  nvchad = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvchad";
    version = "unstable-2022-06-01";
    src = pkgs.fetchFromGitHub {
      owner = "NvChad";
      repo = "NvChad";
      rev = "f78dc305086d7948c3aa31a8de2fb09462654314";
      sha256 = "0vfd41sv6k9gvbm2iy8xq8sm602hwjb6dwn76mz8qs46ds8vp2wa";
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
