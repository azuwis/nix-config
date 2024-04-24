{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.my.lazyvim.custom;
in
{
  options.my.lazyvim.custom = {
    enable = mkEnableOption "LazyVim custom settings";
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."nvim/lua/plugins/custom.lua".source = ./spec.lua;
    xdg.configFile."nvim/lua/config".source = ./config;
  };
}
