{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.programs.lazyvim.ansible;
in
{
  options.programs.lazyvim.ansible = {
    enable = mkEnableOption "LazyVim ansible support";
  };

  config = lib.mkIf cfg.enable {

    programs.lazyvim = {
      config.ansible = ./spec.lua;
      treesitterParsers = [ "yaml" ];
    };
  };
}
