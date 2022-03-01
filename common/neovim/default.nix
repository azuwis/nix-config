{ config, lib, pkgs, ... }:

{
  imports = [
    ./nvchad.nix
    ./update-nix-fetchgit.nix
  ];
  # workaround for updating lua code:
  # rm -rf ~/.config/nvim/plugin/packer_compiled.lua ~/.cache/nvim/ ~/.local/share/nvim/site/
  home.activation.neovim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    rm ~/.cache/nvim/luacache_chunks ~/.cache/nvim/luacache_modpaths
  '';
  home.sessionVariables.EDITOR = "nvim";
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      gcc
      nixpkgs-fmt
      rnix-lsp
      terraform-ls
      tree-sitter
      yaml-language-server
    ] ++ lib.optionals (builtins.hasAttr "stylua" pkgs) [ stylua ];
    extraConfig = ''
      set commentstring=#\ %s
      autocmd! FileType gitcommit exec 'norm gg' | startinsert!
    '';
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
