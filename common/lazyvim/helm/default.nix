{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.programs.lazyvim.helm;
in
{
  options.programs.lazyvim.helm = {
    enable = mkEnableOption "LazyVim helm support";
  };

  config = lib.mkIf cfg.enable {
    programs.lazyvim = {
      extraPackages = [ pkgs.helm-ls ];
      extraPlugins = [ pkgs.vimPlugins.vim-helm ];
      config.helm = ./spec.lua;
    };
  };
}
