{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.wrappers.lazyvim.neogit;
in
{
  options.wrappers.lazyvim.neogit = {
    enable = mkEnableOption "LazyVim neogit";
  };

  config = lib.mkIf cfg.enable {
    wrappers.lazyvim = {
      extraPlugins = with pkgs.vimPlugins; [
        diffview-nvim
        neogit
      ];
      config.neogit = ./spec.lua;
    };
  };
}
