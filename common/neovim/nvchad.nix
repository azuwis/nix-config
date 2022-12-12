{ config, lib, pkgs, ... }:

let
  nvchad = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvchad";
    version = "unstable-2022-11-10";
    src = pkgs.fetchFromGitHub {
      owner = "NvChad";
      repo = "NvChad";
      rev = "c6252937b207e40e72a6d646900c86ab4cd664a1";
      sha256 = "18yjri0vaa6mzg44xyj98j7kbf80isd0n3hcckf02npyab03q2gj";
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
