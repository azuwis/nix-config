{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.neovim;
in
{
  imports = [
    ./nvchad
    ./update-nix-fetchgit
  ];

  options.my.neovim = {
    enable = mkEnableOption (mdDoc "neovim");
  };

  config = mkIf cfg.enable {
    # Clear all caches
    # rm -rf ~/.cache/nvim/ ~/.local/share/nvim/lazy/ ~/.local/share/nvim/nvchad/
    home.sessionVariables.EDITOR = "nvim";
    programs.neovim = {
      enable = true;
      extraPackages = with pkgs; [
        ansible-language-server
        nixpkgs-fmt
        rnix-lsp
        sumneko-lua-language-server
        terraform-ls
        tree-sitter
        yaml-language-server
      ] ++ lib.optionals (builtins.hasAttr "stylua" pkgs) [ stylua ];
      withNodeJs = false;
      withRuby = false;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };
  };
}
