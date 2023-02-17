{ config, lib, pkgs, ... }:

let
  nvchad = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvchad";
    version = "unstable-2023-02-16";
    src = pkgs.fetchFromGitHub {
      owner = "NvChad";
      repo = "NvChad";
      rev = "dc7d35d8a8595b370f16c10bb08ca9ed723d13bd";
      sha256 = "04jj0rf0v01zlzwhj0y1m13173r3wff4z50yn7dshdb8s2qaxpcm";
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
