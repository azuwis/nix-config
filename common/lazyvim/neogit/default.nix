{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.programs.lazyvim.neogit;
in
{
  options.programs.lazyvim.neogit = {
    enable = mkEnableOption "LazyVim neogit";
  };

  config = lib.mkIf cfg.enable {
    programs.lazyvim = {
      extraPlugins = with pkgs.vimPlugins; [
        diffview-nvim
        neogit
      ];
      config.neogit = ./spec.lua;
    };
  };
}
