{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.programs.lazyvim.opentofu;
in
{
  options.programs.lazyvim.opentofu = {
    enable = mkEnableOption "LazyVim opentofu support";
  };

  config = lib.mkIf cfg.enable {

    programs.lazyvim = {
      extraPackages = [ pkgs.tofu-ls ];
      config.opentofu = ./spec.lua;
      treesitterParsers = [ "terraform" ];
    };
  };
}
