{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.my.neovim.enable {
    programs.neovim.extraPackages = with pkgs; [
      # lua/custom/configs/lspconfig.lua
      ansible-language-server
      nil
      terraform-ls
      yaml-language-server
      # lua/custom/configs/null-ls.lua
      nixpkgs-fmt
      shellcheck
      stylua
    ];
    programs.neovim.plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins (plugins: with plugins; [
        hcl
        nix
        yaml
      ]))
      # telescope-fzf-native-nvim
    ];
    programs.neovim.nvchad = {
      enable = true;
      extraLazyPlugins = with pkgs.vimPlugins; [
        csv-vim
        diffview-nvim
        neogit
        null-ls-nvim
        orgmode
        vim-jsonnet
      ];
    };
    xdg.configFile."nvim/lua".source = ./lua;
    xdg.configFile."nvim/ftdetect".source = ./ftdetect;
    xdg.configFile."nvim/snippets".source = ./snippets;
  };
}
