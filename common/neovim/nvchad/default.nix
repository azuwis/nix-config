{ config, lib, pkgs, ... }:

let
  nvchad = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvchad";
    version = "unstable-2023-05-04";
    src = pkgs.fetchFromGitHub {
      owner = "NvChad";
      repo = "NvChad";
      rev = "3dd0fa6c5b0933d9a395e2492de69c151831c66e";
      sha256 = "1i99m7h9vjjrkc891818xa1cjqkw7pfq9wh8c2qd93995qrwvw3d";
    };
    meta.homepage = "https://github.com/NvChad/NvChad/";
  };

  lazyPlugins = pkgs.vimUtils.packDir {myNvchadPackages = {
    start = with pkgs.vimPlugins; [
      nvim-treesitter
    ];
  };};

  lua = pkgs.runCommand "nvchad-lua" { } ''
    cp -r ${./lua} $out
    substituteInPlace $out/custom/chadrc.lua --replace "@plugins@" "${lazyPlugins}"
  '';
in

{
  programs.neovim = {
    # plugins = [ nvchad pkgs.vimPlugins.telescope-fzf-native-nvim ];
    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins (p: [
        p.hcl
        p.lua
        p.nix
        p.vim
        p.yaml
      ]))
      nvchad
    ];
  };
  xdg.configFile."nvim/init.lua".source = "${nvchad}/init.lua";
  xdg.configFile."nvim/lua".source = lua;
  xdg.configFile."nvim/ftdetect".source = ./ftdetect;
}
