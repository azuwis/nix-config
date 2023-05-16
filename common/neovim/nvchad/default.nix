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
      substituteInPlace lua/plugins/init.lua \
        --replace '"NvChad/extensions"' '"NvChad/nvchad-extensions"' \
        --replace '"NvChad/ui"' '"NvChad/nvchad-ui"' \
        --replace '"L3MON4D3/LuaSnip"' '"L3MON4D3/luasnip"' \
        --replace '"numToStr/Comment.nvim"' '"numToStr/comment.nvim"'
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

  nvchad-extensions = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvchad-extensions";
    version = "unstable-2023-05-06";
    src = pkgs.fetchFromGitHub {
      owner = "NvChad";
      repo = "extensions";
      rev = "860ff3609f843d70cccd768f24e341566e02939a";
      sha256 = "1izn7spcnm8dy87l14yg7isfmsmikgb53dw9sgpc2nc97wllhdyg";
    };
    meta.homepage = "https://github.com/NvChad/extensions";
  };

  nvterm = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvterm";
    version = "unstable-2023-05-05";
    src = pkgs.fetchFromGitHub {
      owner = "NvChad";
      repo = "nvterm";
      rev = "5ae78fb332e92447121d2af58a6313189a7799fb";
      sha256 = "0rcj5njhkh1pwaa8d8d15nqqacx1h8j4ijygwhplvszi64kqb9r5";
    };
    meta.homepage = "https://github.com/NvChad/nvterm";
  };

  nvchad-ui = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvchad-ui";
    version = "unstable-2023-05-09";
    src = pkgs.fetchFromGitHub {
      owner = "NvChad";
      repo = "ui";
      rev = "8895e244dadcc17922aa2362227e60ee3b3504ae";
      sha256 = "1f32d63jhk1rfswiqgpnni7n8sgg63lr0dgzkr2d20rm75x092d0";
    };
    meta.homepage = "https://github.com/NvChad/ui";
  };

  lazyPlugins = pkgs.vimUtils.packDir {myNvchadPackages = {
    start = with pkgs.vimPlugins; [
      cmp-buffer
      cmp-nvim-lsp
      cmp-nvim-lua
      cmp-path
      cmp_luasnip
      comment-nvim
      diffview-nvim
      friendly-snippets
      gitsigns-nvim
      indent-blankline-nvim
      luasnip
      neogit
      null-ls-nvim
      nvchad-extensions
      nvchad-ui
      nvim-autopairs
      nvim-cmp
      nvim-colorizer-lua
      nvim-lspconfig
      nvim-tree-lua
      nvim-treesitter
      nvim-web-devicons
      nvterm
      orgmode
      telescope-nvim
      which-key-nvim
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
