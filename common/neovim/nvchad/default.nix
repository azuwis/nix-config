{ config, lib, pkgs, ... }:

let
  nvchad = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvchad";
    version = "unstable-2023-05-13";
    src = pkgs.fetchFromGitHub {
      owner = "NvChad";
      repo = "NvChad";
      rev = "699aeaa44203b62003da8aacd838a5bdac4c2d46";
      sha256 = "1ai0502fh97m13r56r2v8adzgh5fvgiz1nx1bblpzfsf4h2nymrf";
    };
    dependencies = [ base46 ];
    patches = [
      (pkgs.substituteAll {
        src = ./nvchad.patch;
        inherit lazyPlugins;
        lazyPath = pkgs.vimPlugins.lazy-nvim;
      })
    ];
    postPatch = ''
      substituteInPlace lua/plugins/init.lua \
        --replace '"NvChad/extensions"' '"NvChad/nvchad-extensions"' \
        --replace '"NvChad/ui"' '"NvChad/nvchad-ui"' \
        --replace '"L3MON4D3/LuaSnip"' '"L3MON4D3/luasnip"' \
        --replace '"numToStr/Comment.nvim"' '"numToStr/comment.nvim"'
    '';
    meta.homepage = "https://github.com/NvChad/NvChad/";
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
    version = "unstable-2023-05-14";
    src = pkgs.fetchFromGitHub {
      owner = "NvChad";
      repo = "extensions";
      rev = "6025bdbbac5c14b96ba4734e61eaf28db2742676";
      sha256 = "1dfj4a3vh8djgylcc4f7bg7hq2mmg8imizglzbqr0my74v4shd1w";
    };
    meta.homepage = "https://github.com/NvChad/extensions/";
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
    meta.homepage = "https://github.com/NvChad/nvterm/";
  };

  nvchad-ui = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvchad-ui";
    version = "unstable-2023-05-17";
    src = pkgs.fetchFromGitHub {
      owner = "NvChad";
      repo = "ui";
      rev = "35c10e2bccbad92d402fdfefd78202539bfdd7a1";
      sha256 = "0w5wqg8k1ch7a3agjawgz595skwkm6fvbn0v7zxxy2f92yhqnb30";
    };
    meta.homepage = "https://github.com/NvChad/ui/";
  };

  lazyPlugins = pkgs.vimUtils.packDir {lazyPlugins = {
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
  xdg.configFile."nvim/lua".source = ./lua;
  xdg.configFile."nvim/ftdetect".source = ./ftdetect;
}
