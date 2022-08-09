{ config, lib, pkgs, ... }:

{
  # Clear all caches
  # rm -rf ~/.config/nvim/plugin/packer_compiled.lua ~/.cache/nvim/ ~/.local/share/nvim/site/
  imports = [
    ./nvchad.nix
    ./update-nix-fetchgit.nix
  ];
  # workaround for https://github.com/lewis6991/impatient.nvim/issues/42
  # home.activation.neovim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #   $DRY_RUN_CMD rm -f $VERBOSE_ARG ~/.cache/nvim/luacache_chunks ~/.cache/nvim/luacache_modpaths
  # '';
  home.sessionVariables.EDITOR = "nvim";
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      gcc
      nixpkgs-fmt
      rnix-lsp
      sumneko-lua-language-server
      terraform-ls
      tree-sitter
      yaml-language-server
    ] ++ lib.optionals (builtins.hasAttr "stylua" pkgs) [ stylua ];
    plugins = with pkgs.vimPlugins; [
      csv-vim
      vim-jsonnet
      vim-nix
    ];
    withNodeJs = false;
    withRuby = false;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };
}
