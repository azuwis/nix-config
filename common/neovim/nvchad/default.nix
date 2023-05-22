{ config, lib, pkgs, ... }:

let
  nvchad = pkgs.vimPlugins.nvchad.overrideAttrs (old: {
    patches = [
      (pkgs.substituteAll {
        src = ./nvchad.patch;
        inherit lazyPlugins;
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
  });

  lazyPlugins = pkgs.vimUtils.packDir {lazyPlugins = {
    start = with pkgs.vimPlugins; [
      base46
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
      (nvim-treesitter.withPlugins (plugins: with plugins; [
        hcl
        lua
        nix
        vim
        yaml
      ]))
      base46
      lazy-nvim
      nvchad
    ];
    extraLuaConfig = ''
      dofile("${nvchad}/init.lua")
    '';
  };
  xdg.configFile."nvim/lua".source = ./lua;
  xdg.configFile."nvim/ftdetect".source = ./ftdetect;
}
