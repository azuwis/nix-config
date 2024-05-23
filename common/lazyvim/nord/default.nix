{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.my.lazyvim.nord;
in
{
  options.my.lazyvim.nord = {
    enable = mkEnableOption "LazyVim nord theme";
  };

  config = lib.mkIf cfg.enable {
    my.lazyvim.extraPlugins = with pkgs.vimPlugins; [
      {
        name = "nord.nvim";
        path = gbprod-nord;
      }
    ];

    xdg.configFile."nvim/lua/plugins/nord.lua".source = ./spec.lua;
  };
}
