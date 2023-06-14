{ config, lib, pkgs, ... }:

{
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
}
