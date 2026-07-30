{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.programs.lazyvim.jjui;
in
{
  options.programs.lazyvim.jjui = {
    enable = mkEnableOption "LazyVim jjui support";
  };

  config = lib.mkIf cfg.enable {
    programs.lazyvim = {
      extraPackages = [ pkgs.jjui ];
      config.jjui = ./spec.lua;
    };
  };
}
