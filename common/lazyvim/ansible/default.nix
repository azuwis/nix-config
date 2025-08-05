{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.wrappers.lazyvim.ansible;
in
{
  options.wrappers.lazyvim.ansible = {
    enable = mkEnableOption "LazyVim ansible support";
  };

  config = lib.mkIf cfg.enable {

    wrappers.lazyvim = {
      extraPackages = [ pkgs.ansible-language-server ];
      config.ansible = ./spec.lua;
      treesitterParsers = [ "yaml" ];
    };
  };
}
