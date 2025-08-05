{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.wrappers.lazyvim.jujutsu;
in
{
  options.wrappers.lazyvim.jujutsu = {
    enable = mkEnableOption "LazyVim jujutsu support";
  };

  config = lib.mkIf cfg.enable {
    wrappers.lazyvim = {
      extraPlugins = [ pkgs.vimPlugins.hunk-nvim ];
      config.jujutsu = ./spec.lua;
    };
  };
}
