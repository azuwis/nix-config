{ config, lib, pkgs, ... }:

let
  nvchad = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvchad";
    version = "unstable-2022-03-24";
    src = pkgs.fetchFromGitHub {
      owner = "NvChad";
      repo = "NvChad";
      rev = "958a62bc6793abd30c66d1c5e47ddf30dcabcc57";
      sha256 = "04gh2m92pyvkji5wg2aqr1j09hwgd82llx5pr6fyq51mf0jpw446";
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
