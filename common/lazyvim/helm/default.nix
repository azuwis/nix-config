{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.wrappers.lazyvim.helm;
in
{
  options.wrappers.lazyvim.helm = {
    enable = mkEnableOption "LazyVim helm support";
  };

  config = lib.mkIf cfg.enable {
    wrappers.lazyvim = {
      extraPackages = [ pkgs.helm-ls ];
      extraPlugins = [ pkgs.vimPlugins.vim-helm ];
      config.helm = ./spec.lua;
    };
  };
}
