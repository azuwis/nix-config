{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.my.lazyvim.terraform;
in
{
  options.my.lazyvim.terraform = {
    enable = mkEnableOption "LazyVim terraform support";
  };

  config = lib.mkIf cfg.enable {
    programs.neovim.extraPackages = with pkgs; [ terraform-ls ];

    my.neovim.treesitterParsers = [ "hcl" ];

    xdg.configFile."nvim/lua/plugins/terraform.lua".source = ./spec.lua;
  };
}
