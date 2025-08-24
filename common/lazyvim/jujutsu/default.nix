{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.programs.lazyvim.jujutsu;
in
{
  options.programs.lazyvim.jujutsu = {
    enable = mkEnableOption "LazyVim jujutsu support";
  };

  config = lib.mkIf cfg.enable {
    programs.lazyvim = {
      extraPlugins = [ pkgs.vimPlugins.hunk-nvim ];
      config.jujutsu = ./spec.lua;
    };
  };
}
