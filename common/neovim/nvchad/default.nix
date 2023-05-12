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
    postPatch = ''
      sed -i -e 's|^local lazypath =.*|local lazypath = "${pkgs.vimPlugins.lazy-nvim}"|' init.lua
    '';
  };

  base46 = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "base46";
    version = "unstable-2023-05-06";
    src = pkgs.fetchFromGitHub {
      owner = "NvChad";
      repo = "base46";
      rev = "bad87b034430b0241d03868c3802c2f1a4e0b4be";
      sha256 = "1nplnd4f5wzwkbbfw9nnpm3jdy0il4wbqh5gdnbh9xmldb3lf376";
    };
    meta.homepage = "https://github.com/NvChad/base46/";
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
      base46
      nvchad
    ];
  };
  xdg.configFile."nvim/init.lua".source = "${nvchad}/init.lua";
  xdg.configFile."nvim/lua".source = lua;
  xdg.configFile."nvim/ftdetect".source = ./ftdetect;
}
