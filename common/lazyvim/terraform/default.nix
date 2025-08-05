{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.wrappers.lazyvim.terraform;
in
{
  options.wrappers.lazyvim.terraform = {
    enable = mkEnableOption "LazyVim terraform support";
  };

  config = lib.mkIf cfg.enable {

    wrappers.lazyvim = {
      extraPackages = [ pkgs.terraform-ls ];
      config.terraform = ./spec.lua;
      treesitterParsers = [ "hcl" ];
    };
  };
}
