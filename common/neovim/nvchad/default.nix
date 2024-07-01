{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.my.neovim.enable {
    programs.neovim.extraPackages = with pkgs; [
      # lua/custom/configs/lspconfig.lua
      ansible-language-server
      lua-language-server
      nil
      terraform-ls
      yaml-language-server
      # lua/custom/configs/null-ls.lua
      nixpkgs-fmt
      shellcheck
      stylua
    ];

    # https://github.com/nvim-treesitter/nvim-treesitter#i-get-query-error-invalid-node-type-at-position
    my.neovim.treesitterParsers = [
      "c"
      "hcl"
      "lua"
      "nix"
      "yaml"
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
