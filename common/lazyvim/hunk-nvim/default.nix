{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.programs.lazyvim.hunk-nvim;
in
{
  options.programs.lazyvim.hunk-nvim = {
    enable = mkEnableOption "LazyVim hunk-nvim support";
  };

  config = lib.mkIf cfg.enable {
    programs.lazyvim = {
      extraPlugins = [ pkgs.vimPlugins.hunk-nvim ];
      config.hunk-nvim = ./spec.lua;
    };
  };
}
