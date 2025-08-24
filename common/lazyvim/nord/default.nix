{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.programs.lazyvim.nord;
in
{
  options.programs.lazyvim.nord = {
    enable = mkEnableOption "LazyVim nord theme";
  };

  config = lib.mkIf cfg.enable {
    programs.lazyvim = {
      extraPlugins = [
        {
          name = "nord.nvim";
          path = pkgs.vimPlugins.gbprod-nord;
        }
      ];
      excludePlugins = with pkgs.vimPlugins; [
        {
          name = "catppuccin";
          path = catppuccin-nvim;
        }
        tokyonight-nvim
      ];
      config.nord = ./spec.lua;
    };
  };
}
