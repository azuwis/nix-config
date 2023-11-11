{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.my.neovim.enable {
    my.lazyvim.enable = true;
    my.lazyvim.ansible.enable = true;
    my.lazyvim.neogit.enable = true;
    my.lazyvim.nix.enable = true;
    my.lazyvim.nord.enable = true;
    my.lazyvim.terraform.enable = true;

    my.lazyvim.extraSpec = ''
      { "echasnovski/mini.indentscope", enabled = false, },
      {
        "nvim-lualine/lualine.nvim",
        opts = {
          options = {
            component_separators = "",
            section_separators = { left = "", right = "" },
          },
        },
      },
    '';

    xdg.configFile."nvim/lua/config".source = ./lua/config;

  };
}
