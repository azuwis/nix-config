{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.programs.lazyvim.terraform;
in
{
  options.programs.lazyvim.terraform = {
    enable = mkEnableOption "LazyVim terraform support";
  };

  config = lib.mkIf cfg.enable {

    programs.lazyvim = {
      extraPackages = [ pkgs.terraform-ls ];
      config.terraform = ./spec.lua;
      treesitterParsers = [ "hcl" ];
    };
  };
}
